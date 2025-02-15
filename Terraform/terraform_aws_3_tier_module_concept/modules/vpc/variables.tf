variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}
variable "environment" {
  description = "The environment in which the resources are created"
  type        = string
}

/*
variable "az"{
  description = "The availability zones for the subnets"
  type        = string
}
*/