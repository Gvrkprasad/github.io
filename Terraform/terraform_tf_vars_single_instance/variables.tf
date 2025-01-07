variable "region" {
  description = "The region in which the resources will be created."
  type = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type = string 
}
variable "env" {
  description = "The environment in which the resources will be created."
  type = string
}
variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type = string
}
variable "availability_zone" {
  description = "The availability zone in which the resources will be created."
  type = string
}
variable "ami" {
  description = "The AMI to use for the EC2 instance."
  type = string
}
variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type = string
}
variable "key_name" {
  description = "The key pair name for the EC2 instance."
  type = string
}

