variable "region" {
  description = "The region in which the resources will be created."
  type = string
}
variable "ami_id" {
  description = "The AMI to use for the EC2 instance."
  type = string
}
variable "instance_type" {
  description = "The type of EC2 instance to launch."
  type = string
}
variable "key_name" {
  description = "The name of the EC2 key pair."
  type = string
}
variable "vpc_name" {
  description = "The name of the VPC."
  type = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type = string
}

/*
variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type = string
} 

variable "count" {
  description = "The number of subnets to create."
  type = number
} 
*/

variable "env" {
  description = "The environment in which the resources will be created."
  type = string
}
