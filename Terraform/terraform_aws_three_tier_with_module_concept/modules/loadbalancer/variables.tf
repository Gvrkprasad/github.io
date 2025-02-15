variable "public_subnet_ids" {
  description = "Public subnet IDs for the web load balancer"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the app load balancer"
}

variable "web_lb_sg_id" {
  description = "Security group ID for the web load balancer"
}

variable "app_lb_sg_id" {
  description = "Security group ID for the app load balancer"
}

variable "vpc_id" {
  description = "VPC ID"
}
variable "environment" {
  description = "environment of infrstructure"
}