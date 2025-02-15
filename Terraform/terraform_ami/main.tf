provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "glps" {
  most_recent = true


  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


  owners = ["137112412989"] # Canonical
}


data "aws_availability_zones" "name" {
  state = "available"
}

# Adding existing Default VPC
data "aws_vpc" "Default-vpc" {
  id = "vpc-06a884d7ce704e703"
}

# Adding existing Default Subnet
data "aws_subnet" "Default-subnet" {
  id     = "subnet-07d80158cfcc75897"
  vpc_id = data.aws_vpc.Default-vpc.id
}

# Adding Amzn Linux instance from existing ami
resource "aws_instance" "web" {
  ami                         = data.aws_ami.glps.image_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnet.Default-subnet.id
  key_name                    = "glpsk371-linux"

  tags = {
    Name = "Instance1"
  }
}

# Copy Image From Existing Instance 
resource "aws_ami_from_instance" "glps_ami" {
  name               = "terraform-ami"
  source_instance_id = aws_instance.web.id
}

# Launching New Ec2 instance from Copied ami from Web_instance
resource "aws_instance" "app" {
  ami                         = aws_ami_from_instance.glps_ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnet.Default-subnet.id
  key_name = "glpsk371-linux"

  tags = {
    Name = "Instance2"
  }
}

