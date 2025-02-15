variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ami" {
  description = "ami_id for instance"
  type = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
}

variable "web_instance_sg" {
  description = "security for public instance"
  type = string
}

variable "app_instance_sg" {
  description = "security for private instance"
  type = string
}

variable "key_name" {
  description = "Key name for SSH access"
  type        = string
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


variable "web_tg_alb_arn" {}

variable "app_tg_alb_arn" {}

variable "web_subnet_ids" {}

variable "app_subnet_ids" {}