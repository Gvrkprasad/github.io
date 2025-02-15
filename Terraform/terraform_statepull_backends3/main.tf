provider "aws" {
   region = "ap-south-1"
}

terraform {
  backend "s3" {
       bucket = "dorababu-terraform-bucket"
       key = "terraform/state.tfstate"
       region = "ap-south-1"
   }
}
   
data "aws_iam_user" "example" {
  user_name = "glpskumar"
}