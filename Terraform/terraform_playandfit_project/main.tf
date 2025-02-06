module "backend" {
  source                  = "./modules/backend"
  lambda_filename         = var.lambda_filename
  lambda_function_name    = var.lambda_function_name
  lambda_runtime          = var.lambda_runtime
  lambda_handler          = var.lambda_handler
  database_url            = module.database.rds_endpoint
  db_username             = var.db_username
  db_password             = var.db_password
  db_name                 = var.db_name
  sns_topic_arn           = module.sns.sns_topic_arn
  iam_lambda_rds_role_arn = module.iam.iam_lambda_rds_role_arn
}

module "database" {
  source           = "./modules/database"
  db_storage       = var.db_storage
  db_instance_type = var.db_instance_type
  db_engine        = var.db_engine
  db_version       = var.db_version
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  environment      = var.environment
  subnet_id        = module.vpc.subnet_id
  db_sgid          = module.security_group.db_sgid
}

module "frontend" {
  source        = "./modules/frontend"
  bucket_name   = var.bucket_name
  environment   = var.environment
  s3object_path = var.s3object_path
}

module "iam" {
  source         = "./modules/iam"
  environment    = var.environment
  s3_bucket_name = module.frontend.s3_bucket_name
  rds_arn        = module.database.rds_arn
  sns_topic_arn  = module.sns.sns_topic_arn
  s3_bucket_arn  = module.frontend.s3_bucket_arn
  lambda_fn_arn  = module.backend.lambda_fn_arn
}

module "sns" {
  source       = "./modules/sns"
  environment  = var.environment
  sns_endpoint1 = var.sns_endpoint1
  sns_endpoint2 = var.sns_endpoint2
}

module "vpc" {
  source = "./modules/vpc"

}

module "security_group" {
  source      = "./modules/security_group"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

