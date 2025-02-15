variable "web_ami_id" {
  description = "AMI ID for the web instances"
}

variable "app_ami_id" {
  description = "AMI ID for the app instances"
}

variable "instance_type" {
  description = "Instance type for EC2 instances (e.g., t2.micro)"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for instances"
}

variable "web_desired_capacity" {
  description = "Desired capacity for the web autoscaling group"
  type        = number
  default     = 2
}

variable "app_desired_capacity" {
  description = "Desired capacity for the app autoscaling group"
  type        = number
  default     = 2
}

variable "web_lb_sg_id" {
  description = "Security group ID for the web instances"
}

variable "app_lb_sg_id" {
  description = "Security group ID for the app instances"
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the web instances"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the app instances"
}

variable "environment" {
    description = "Environment name (e.g., dev, staging, prod)"
}

variable "web_lb_tg_arn" {
  
}
variable "app_lb_tg_arn" {
  
}