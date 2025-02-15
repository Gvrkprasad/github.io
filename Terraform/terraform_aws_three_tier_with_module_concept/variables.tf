variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = map(string)
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = map(string)
}

variable "instance_type" {
  description = "Instance type for EC2 instances (e.g., t2.micro)"
  type        = map(string)
}

variable "key_name" {
  description = "Name of the SSH key pair to use for instances"
  type        = string
}

variable "web_ami_id" {
  description = "AMI ID for the web instances"
  type        = string
}

variable "app_ami_id" {
  description = "AMI ID for the app instances"
  type        = string
}

variable "iam_user1" {
  description = "Name of the IAM user"
  type        = map(string)
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = map(string)
}
variable "env_bucket_name" {
  description = "Name of the environment S3 bucket"
  type        = map(string)
}

variable "db_engine" {
  description = "Database engine (e.g., mysql, postgres)"
  type        = string
  default     = "mysql"
}
variable "db_username" {
  description = "Username for the database"
  type        = map(string)
}
variable "db_password" {
  description = "Password for the database"
  type        = map(string)
}

variable "ec2_ami" {
  description = "AMI ID for the EC2 instances"
  type        = map(string)
}
variable "ec2_instance_type" {
  description = "Instance type for the EC2 instances"
  type        = map(string)
}
variable "ec2_keypair" {
  description = "Key pair name for the EC2 instances"
  type        = map(string)
}
variable "file_path" {
  description = "Path to the file to be used"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
}