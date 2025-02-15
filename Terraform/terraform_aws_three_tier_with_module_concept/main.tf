module "vpc" {
  source      = "./modules/vpc"
  environment = lookup(var.environment, terraform.workspace)
  cidr_block  = lookup(var.cidr_block, terraform.workspace)
}

module "security" {
  source              = "./modules/security"
  environment         = lookup(var.environment, terraform.workspace)
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidr  = module.vpc.public_subnet_cidr
  private_subnet_cidr = module.vpc.private_subnet_cidr

}

module "cloudwatch" {
  source      = "./modules/cloudwatch"
  environment = lookup(var.environment, terraform.workspace)
}

module "compute" {
  source             = "./modules/compute"
  environment        = lookup(var.environment, terraform.workspace)
  web_ami_id         = var.web_ami_id
  app_ami_id         = var.app_ami_id
  instance_type      = lookup(var.instance_type, terraform.workspace)
  key_name           = var.key_name
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  web_lb_sg_id       = module.security.web_lb_sg_id
  app_lb_sg_id       = module.security.app_lb_sg_id
  web_lb_tg_arn      = module.loadbalancer.web_lb_tg_arn
  app_lb_tg_arn      = module.loadbalancer.app_lb_tg_arn
}

module "loadbalancer" {
  source             = "./modules/loadbalancer"
  environment        = lookup(var.environment, terraform.workspace)
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  web_lb_sg_id       = module.security.web_lb_sg_id
  app_lb_sg_id       = module.security.app_lb_sg_id
}

module "database" {
  source              = "./modules/database"
  environment         = lookup(var.environment, terraform.workspace)
  database_subnet_ids = module.vpc.database_subnet_ids
  db_sg_id            = module.security.db_sg_id
  db_username         = lookup(var.db_username, terraform.workspace)
  db_password         = lookup(var.db_password, terraform.workspace)
}

module "ec2" {
  source            = "./modules/ec2"
  ec2_ami           = lookup(var.ec2_ami, terraform.workspace)
  ec2_instance_type = lookup(var.ec2_instance_type, terraform.workspace)
  ec2_keypair       = lookup(var.ec2_keypair, terraform.workspace)
  environment       = lookup(var.environment, terraform.workspace)
  cidr_block        = lookup(var.cidr_block, terraform.workspace)
  web_lb_sg_id      = module.security.web_lb_sg_id
  vpc_id            = module.vpc.vpc_id
}

module "iam_users" {
  source          = "./modules/iam_users"
  iam_user1       = lookup(var.iam_user1, terraform.workspace)
  environment     = lookup(var.environment, terraform.workspace)
  env_bucket_name = lookup(var.env_bucket_name, terraform.workspace)
}

module "s3_bucket" {
  source          = "./modules/s3_bucket"
  environment     = lookup(var.environment, terraform.workspace)
  bucket_name     = lookup(var.bucket_name, terraform.workspace)
  env_bucket_name = lookup(var.env_bucket_name, terraform.workspace)
}

module "s3_sns_lamda" {
  source = "./modules/s3_sns_lamda"
  environment = lookup(var.environment, terraform.workspace)
  bucket_name = lookup(var.bucket_name, terraform.workspace)
  sns_topic_name = var.sns_topic_name
  s3_bucket_arn = module.s3_bucket.s3_bucket_arn
  s3_bucket = module.s3_bucket.s3_bucket
  file_path = var.file_path
}

module "sns" {
  source          = "./modules/sns"
  env_bucket_name = lookup(var.env_bucket_name, terraform.workspace)
  s3_env_bucket_arn = module.s3_bucket.s3_env_bucket_arn
  file_path = var.file_path
}

# Terraform tfstate file backup to s3 bucket

terraform {
  backend "s3" {
    bucket = "dorababu-terraform-bucket" # Replace with the bucket name created in Step 1
    key    = "terraform/state.tfstate"
    region = "ap-south-1" # Replace with your region
  }
} 