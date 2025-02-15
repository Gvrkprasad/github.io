data "aws_availability_zones" "ec2" {
    state = "available"
    exclude_names = [ "ap-south-1c" ]
}

/*
resource "aws_vpc" "ec2" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      Name = "${var.environment}_ec2vpc"
    }
} */

resource "aws_subnet" "ec2" {
  count=1 
  vpc_id = var.vpc_id
  cidr_block = cidrsubnet(var.cidr_block, 12, count.index + 1)
  map_public_ip_on_launch= true
  availability_zone = data.aws_availability_zones.ec2.names[count.index]
  tags = {
    Name = "${var.environment}_ec2subnet_${count.index}"
  }
}

resource "aws_instance" "ec2" {
    count = 1
    ami = var.ec2_ami
    instance_type = var.ec2_instance_type
    key_name = var.ec2_keypair
    subnet_id = aws_subnet.ec2[count.index].id
    security_groups = [var.web_lb_sg_id]
    
    tags = {
      Name = "${var.environment}_ec2_${count.index}"
    }
}