
# Launch Template for Web Tier
resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-template"
  image_id      = "ami-053b12d3152c0cc71" # Ubuntu AMI
  instance_type = "t3.micro"
  key_name = data.aws_key_pair.existing.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.alb.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              echo "Hello from Dora, this is a sample webserver " > /var/www/html/index.html
              sudo systemctl enable apache2
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-web-server-lt"
    }
  }
}

# Launch Template for Application Tier
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app-template"
  image_id      = "ami-053b12d3152c0cc71" # Ubuntu AMI
  instance_type = "t3.micro"
  key_name = data.aws_key_pair.existing.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.app.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              echo "Hello from Dora, this is a sample webserver " > /var/www/html/index.html
              sudo systemctl enable apache2
              EOF
  )

  

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-app-server-lt"
    }
  }
}

# Auto Scaling Group for Application Tier
resource "aws_autoscaling_group" "app" {
  desired_capacity    = 2
  max_size           = 4
  min_size           = 1
  target_group_arns  = [aws_lb_target_group.app.arn]
  vpc_zone_identifier = aws_subnet.private_app[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-app-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "web" {
  desired_capacity    = 2
  max_size           = 4
  min_size           = 1
  target_group_arns  = [aws_lb_target_group.web.arn]
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-web-asg"
    propagate_at_launch = true
  }
}

