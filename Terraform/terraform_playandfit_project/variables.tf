variable "lambda_filename" {
  description = "The filename of the Lambda function code"
  type        = string
}
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}
variable "lambda_runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}
variable "lambda_handler" {
  description = "The handler for the Lambda function"
  type        = string
}

/*
variable "database_url" {
description = "Spring backend connection to Database"
type        = string
}
*/

variable "sns_endpoint1" {
  description = "The endpoint for the SNS topic"
  type        = string
}
variable "sns_endpoint2" {
  description = "The endpoint for the SNS topic"
  type        = string
}



variable "db_instance_type" {
  description = "The instance type for the database"
  type        = string
}
variable "db_storage" {
  description = "The allocated storage for the database in GB"
  type        = number
}
variable "db_engine" {
  description = "The database engine"
  type        = string
}
variable "db_version" {
  description = "The version of the database engine"
  type        = string
}
variable "db_name" {
  description = "The name of the database"
  type        = string
}
variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
variable "s3object_path" {
  description = "The path to the S3 object"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment"
  type        = string
}

