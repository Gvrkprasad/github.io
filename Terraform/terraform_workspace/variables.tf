variable "region" {
  description = "Region for this service"
  type = string
}
variable "key_pair" {
  description = "Key_pair for the instance"
  type = string
}
variable "bucket_name" {
  description = "S3 Bucket name"
  type = map(string)
}
variable "environment" {
  description = "environment name for all the services"
  type = string
}

/*
variable "backend_key" {
  description = "Path to the state file inside the S3 bucket for the backend"
  type        = string
}
*/
