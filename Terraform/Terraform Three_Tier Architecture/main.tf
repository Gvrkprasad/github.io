terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"         # update region as per your requirement
}

# Use existing key pair
data "aws_key_pair" "existing" {
  key_name = "glpsk370-****"    # replace with your aws ubuntu instance key_pair
}
