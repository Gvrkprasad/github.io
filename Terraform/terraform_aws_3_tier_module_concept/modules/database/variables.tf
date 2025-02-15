variable "environment" {
  description = "The environment to deploy the database to"
  type        = string
}
variable "database_subnet_ids" {}
variable "identifier" {}
variable "storage" {}
variable "storage_type" {}
variable "instance_class" {}
variable "engine" {}
variable "engine_version" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "db_sg_id" {}
