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

resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "babu_vpc"
    }
}

resource "aws_security_group" "default" {
    name        = "main"
    description = "Main security group"
    vpc_id      = aws_vpc.default.id
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
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
}
resource "aws_subnet" "frontend" {
    vpc_id            = aws_vpc.default.id
    cidr_block        = "10.0.1.0/28"
    availability_zone = "ap-south-1a"
}

resource "aws_subnet" "backend" {
    vpc_id            = aws_vpc.default.id
    cidr_block        = "10.0.2.0/28"
    availability_zone = "ap-south-1b"
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]

  tags = {
    Name = "babu_DB_subnet_group"
  }
}
resource "aws_db_instance" "default" {
  identifier           = "main"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = "securepassword"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.default.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}