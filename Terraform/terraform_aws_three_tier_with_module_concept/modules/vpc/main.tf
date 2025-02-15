data "aws_availability_zones" "az" {
  state = "available"

  # exclude or blacklist particular az
  # exclude_names = ["ap-south-1b"]
}


resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "${var.environment}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 2)
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "${var.environment}-private-subnet-${count.index}"
  }
}

resource "aws_subnet" "database" {
  count = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 4)
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "${var.environment}-database-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.environment}-nat-gateway"
  }
}

resource "aws_eip" "nat" {
  
}

resource "aws_route_table" "custom" {
    vpc_id = aws_vpc.main.id
  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main.id
    }
  tags = {
    Name = "${var.environment}-Custom_rt"
  }
}

resource "aws_route_table_association" "custom"{
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.custom.id
 
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

   route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-main_rt"
  }
}

resource "aws_route_table_association" "app" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.main.id
}

  
