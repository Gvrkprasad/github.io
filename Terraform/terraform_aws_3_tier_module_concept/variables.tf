variable "environment" {
  description = "value of the environment"
  type = string
}
variable "ami" {
  description = "img_id for instance"
  type = string
}
variable "cidr_block" {
  description = "value of the vpc_cidr"
  type = string
}
variable "instance_type" {
  description = "value of the instance_type"
  type = string
}
variable "key_name" {
  description = "value of the key_name"
  type = string
}

variable "desired_capacity_web_asg" {
  description = "Desired capacity instance for web asg"
  type = number
}
variable "max_size_web_asg" {
  description = "maximum launch limit of instances for web asg"
  type = number
}
variable "min_size_web_asg" {
  description = "minimum capacity limit for instances for web asg"
  type = number
}

variable "desired_capacity_app_asg" {
  description = "Desired capacity instance for app asg"
  type = number
}
variable "max_size_app_asg" {
  description = "maximum launch limit of instances for app asg"
  type = number
}
variable "min_size_app_asg" {
  description = "minimum capacity limit for instances for app asg"
  type = number
}

variable "identifier" {
  description = "db server identifier name"
  type = string
}
variable "storage" {
  description = "database storage"
  type = number
}
variable "storage_type" {
  description = "database storage type"
  type = string
}
variable "instance_class" {
  description = "database instance type"
  type = string
}
variable "engine" {
  description = "database engine"
  type = string
}
variable "engine_version" {
  description = "database engine version"
  type = string
}
variable "db_name" {
  description = "name of the database"
  type = string
}
variable "username" {
  description = "database username"
  type        = string
}
variable "password" {
  description = "database password"
  type        = string
  sensitive   = true
}

/*
variable "az" {
  description = "available zone for subnets"
  default = "module.vpc.data.aws_availability_zones.az.names[count.index]"
}
*/

