terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">4.3.0 , <4.5.0"
    }
  }
}

provider "aws" {
  # access_key = "AWS ACCESS KEY"
  # secret_key = "AWS SECRET KEY"
  region = "ap-south-1"
}

data "aws_key_pair" "ubuntu_key" {
  key_name = "glpsk371-ubuntu"
}