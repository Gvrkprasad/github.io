

# Fetching the availability zones dynamically
data "aws_availability_zones" "list" {
    state = "available"
}
 
# VPC
resource "aws_vpc" "glps_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.env}-vpc"
    }
}

# Subnet
resource "aws_subnet" "glps_subnet" {
    count = 2
    vpc_id = aws_vpc.glps_vpc.id
    cidr_block = "${cidrsubnet(aws_vpc.glps_vpc.cidr_block, 8, count.index)}"
    availability_zone = data.aws_availability_zones.list.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.env}-subnet-${count.index}"
    }
}

# Route Table
resource "aws_route_table" "glps_rt" {
    vpc_id = aws_vpc.glps_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.glps_igw.id
    }
}

# Route Table Association
resource "aws_route_table_association" "glps_rta" {
    count = 2
    subnet_id = element(aws_subnet.glps_subnet[*].id, count.index)
    route_table_id = aws_route_table.glps_rt.id
}


# Internet Gateway
resource "aws_internet_gateway" "glps_igw" {
    vpc_id = aws_vpc.glps_vpc.id

    tags = {
        Name = "${var.env}-igw"
    }
}
