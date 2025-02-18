resource "aws_vpc" "eks" {    
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}_vpc"
  }

}
