output "lambda_fn_arn" {
  value = module.backend.lambda_fn_arn
}
output "api_url" {
  value = module.backend.api_url
}

output "rds_endpoint" {
  value = module.database.rds_endpoint
}

output "database_url" {
  value = module.database.rds_endpoint
}
output "s3_bucket_name" {
  value = module.frontend.s3_bucket_name
}
output "s3_bucket_arn" {
  value = module.frontend.s3_bucket_arn
}

output "s3_static_url" {
  value = module.frontend.s3_static_url2
}


output "iam_lambda_rds_role_arn" {
  value = module.iam.iam_lambda_rds_role_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "subnet_id" {
  value = module.vpc.subnet_id
}
output "defvpc_cidr" {
  value = module.vpc.defvpc_cidr
}

output "sns_topic_arn" {
  value = module.sns.sns_topic_arn
}

output "db_sgid" {
  value = module.security_group.db_sgid
}

output "rds_arn" {
  value = module.database.rds_arn
}