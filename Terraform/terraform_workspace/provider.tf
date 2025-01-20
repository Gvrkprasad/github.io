terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.6"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_key_pair" "ubuntu" {
  key_name= var.key_pair
}