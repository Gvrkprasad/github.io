terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.14.0"
    }
  }
  # Uncomment this block to use Terraform Cloud for this tutorial
  cloud {
    organization = "FS_UHG_OPTUM"
    workspaces {
      name = "aws_s3_iam_practice"
    }
  }
  #
  required_version = "~> 1.1"
}