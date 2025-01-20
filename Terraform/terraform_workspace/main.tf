module "s3" {
    source = "./modules/s3"
    bucket_name = lookup(var.bucket_name, terraform.workspace)
    environment = var.environment

}

/*
terraform {
  backend "s3" {
    bucket         = "glps-terraform"
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"
    
  }
}
*/


