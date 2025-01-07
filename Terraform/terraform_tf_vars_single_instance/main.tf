terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.67.0"
        }
    }
}
provider "aws" {
    region = var.region
    
}

resource "aws_vpc" "glps_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.env}_vpc"
    }
}

resource "aws_internet_gateway" "glps_igw" {
    vpc_id = aws_vpc.glps_vpc.id
    tags = {
        Name = "${var.env}_igw"
    }   
} 

resource "aws_route_table" "glps_rt" {
    
    vpc_id = aws_vpc.glps_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.glps_igw.id
    }
    tags = {
        Name = "${var.env}_rt"
    }
}

resource "aws_route_table_association" "glps_rta" {
    subnet_id      = aws_subnet.glps_subnet.id
    route_table_id = aws_route_table.glps_rt.id
}

resource "aws_subnet" "glps_subnet" {
    vpc_id                  = aws_vpc.glps_vpc.id
    cidr_block              = var.subnet_cidr
    availability_zone       = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.env}_subnet"
    }
}

resource "aws_instance" "glps_instance" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name      = var.key_name
    subnet_id     = aws_subnet.glps_subnet.id
    vpc_security_group_ids = [aws_security_group.glps_sg.id]
    tags = {
        Name = "${var.env}_instance"
    }
  
}

resource "aws_security_group" "glps_sg" {
    name        = "glps_sg"
    vpc_id      = aws_vpc.glps_vpc.id
    ingress {
        from_port   = 22
        to_port     = 22
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
        Name = "${var.env}_sg"
    }
}