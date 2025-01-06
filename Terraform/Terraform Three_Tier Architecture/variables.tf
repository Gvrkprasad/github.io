variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dorababu"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_port" {
  description = "Port for application"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port for database"
  type        = number
  default     = 3306
}