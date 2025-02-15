variable "vpc_id" {
  description = "VPC ID"
}

variable "public_subnet_cidr" {
  description = "CIDR blocks of web subnets"
}

variable "private_subnet_cidr" {
  description = "CIDR blocks of app subnets"
}

variable "environment" {
  description = "environment of infrstructure"
}