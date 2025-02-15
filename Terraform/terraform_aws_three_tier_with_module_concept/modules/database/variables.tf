variable "db_username" {
  description = "Database username"
}

variable "db_password" {
  description = "Database password"
}

variable "database_subnet_ids" {
  description = "Private subnet IDs for the database"
}

variable "db_sg_id" {
  description = "Security group ID for the database"
}

variable "environment" {
  description = "environment of infrstructure"
}