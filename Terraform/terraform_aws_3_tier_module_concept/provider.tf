terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_key_pair" "ubuntu" {
  key_name = "glpsk370-ubuntu"
}   