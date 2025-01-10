terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Data Source for AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Variables
variable "key_pair" {
  default = "glpsk370-****"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Dorababu"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count                  = 2
  vpc_id                 = aws_vpc.main.id
  cidr_block             = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.environment}-pub_subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                  = 2
  vpc_id                 = aws_vpc.main.id
  cidr_block             = "10.0.${count.index + 2}.0/24"
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.environment}-private_subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count                  = 2
  vpc_id                 = aws_vpc.main.id
  cidr_block             = "10.0.${count.index + 4}.0/24"
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.environment}-db_subnet-${count.index + 1}"
  }
}

# Elastic IPs for NAT Gateway
resource "aws_eip" "nat" {
  count = 1
  vpc = true
  tags = {
    Name = "${var.environment}-nat_eip-${count.index + 1}"
  }
}


# Nat Gateway
resource "aws_nat_gateway" "main" {
  count = 1
  subnet_id = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id
  tags = {
    Name = "${var.environment}-nat_gw-${count.index + 1}"
  }
}



# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${var.environment}-database-rt"
  }
}

resource "aws_route_table_association" "database" {
  count          = 2
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.database.id
}


# Security Groups
resource "aws_security_group" "public" {
  name_prefix = "public-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-public_sg"
  }

}

resource "aws_security_group" "private" {
  name_prefix = "private-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.public.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-private_sg"
  }
}

resource "aws_security_group" "db" {
  name_prefix = "db-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.private.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-db_sg"
  }

}

# Public Auto Scaling Group and Load Balancer
resource "aws_launch_template" "public" {
  name          = "public-lc"
  image_id      = "ami-053b12d3152c0cc71" # Replace with a valid Ubuntu AMI ID
  instance_type = "t3.micro"
  key_name      = var.key_pair
 

network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.public.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl start acpache2
              systemctl enable apache2
              echo "Hello from babu sai,this is web server" > /var/www/html/index.html
              EOF
  )
    
}  

resource "aws_autoscaling_group" "public" {
  vpc_zone_identifier  = aws_subnet.public[*].id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2

  launch_template {
    id      = aws_launch_template.public.id
    version = "$Latest"
  }
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 100 # Time (in seconds) for the new instance to stabilize
    }
  }

  tag {
    key                 = "Name"
    value               = "public-asg"
    propagate_at_launch = true
  }
}


resource "aws_lb" "public" {
  name               = "public-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.environment}-public_lb"
  }
}

# Target Group for Public Instances
resource "aws_lb_target_group" "public" {
  name     = "public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    port                = "traffic-port"
  }
}

# ALB Listener
resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
    
  }
}

# Private Auto Scaling Group and Load Balancer
resource "aws_launch_template" "private" {
  name          = "private-lc"
  image_id      = "ami-053b12d3152c0cc71" # Replace with a valid Ubuntu AMI ID
  instance_type = "t3.micro"
  key_name      = var.key_pair


network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.private.id]
  }

    user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl start acpache2
              systemctl enable apache2
              echo "Hello from babu sai,this is application server" > /var/www/html/index.html
              EOF
    )
}

resource "aws_autoscaling_group" "private" {
  vpc_zone_identifier  = aws_subnet.private[*].id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2

    launch_template {
        id      = aws_launch_template.private.id
        version = "$Latest"
    }
    instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 300 # Time (in seconds) for the new instance to stabilize
    }
  }
    
        tag {
            key                 = "Name"
            value               = "private-asg"
            propagate_at_launch = true
        }
}

resource "aws_lb" "private" {
  name               = "private-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private.id]
  subnets            = aws_subnet.private[*].id

  tags = {
    Name = "${var.environment}-private_lb"
  }
}

# Target Group for Private Instances
resource "aws_lb_target_group" "private" {
  name     = "private-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    port                = "traffic-port"
  }
}

# ALB Listener
resource "aws_lb_listener" "private" {
  load_balancer_arn = aws_lb.private.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private.arn
    
  }
}


resource "aws_db_subnet_group" "main" {
  name       = "glp-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}



# SQL Database
resource "aws_db_instance" "database" {
  identifier           = "database-db"  
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = "mysql"
  engine_version      = "8.0.39"
  instance_class      = "db.t4g.micro"
  db_name             = "doradb"
  username            = "dorababu"
  password            = "sivakaladorababu" # Change this in production
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

}

output "db_address" {
  value = aws_db_instance.database.address
}


