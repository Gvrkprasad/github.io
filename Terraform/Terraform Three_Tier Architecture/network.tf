data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

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

# Public Subnets
resource "aws_subnet" "public" {
  count                     = 2
  vpc_id                    = aws_vpc.main.id
  cidr_block                = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch   = true
  availability_zone         = element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "${var.environment}-public-web-subnet-${count.index + 1}"
  }
}

# Private Subnets for Application Layer
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "${var.environment}-private-app-subnet-${count.index + 1}"
  }
}

# Private Subnets for Database Layer
resource "aws_subnet" "database" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "${var.environment}-database-subnet-${count.index + 1}"
  }
}



# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat_gw"
  }
}

# Elastic IPs for NAT Gateway
resource "aws_eip" "nat" {
  count = 1
  vpc   = true

  tags = {
    Name = "${var.environment}-nat-eip"
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
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
} 

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[0].id
  }
  tags = {
    Name = "${var.environment}-db-rt"
  }  
} 

resource "aws_route_table_association" "database" {
  count          = 2
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
} 