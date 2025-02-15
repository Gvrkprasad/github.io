variable "environment" {
  description = "Environment name"
  type        = string
}

variable "web_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "List of Private subnet Id's"
  type = list(string)
}

variable "web_lb_sg" {
  description = "Security group ID for the public load balancer"
  type        = string
}

variable "app_lb_sg" {
  description = "Security group ID for the application load balancer"
  type        = string
}

variable "vpc_id" {
  description = "VPC id for the arcitecture"
  type = string
}

