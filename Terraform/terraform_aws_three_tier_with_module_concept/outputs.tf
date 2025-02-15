output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet Id"
  value       = module.vpc.database_subnet_ids
}

/*
output "iam_user_password" {
  description = "iam_user password"
  value       = module.iam_users.iam_user_password
  sensitive   = true
} 
*/

output "public_subnet_cidr" {
  description = "Public subnet cidr"
  value       = module.vpc.public_subnet_cidr
}

output "private_subnet_cidr" {
  description = "Private subnet cidr"
  value       = module.vpc.private_subnet_cidr
}

output "web_asg_id" {
  description = "Web autoscaling group"
  value       = module.compute.web_asg_id
}

output "app_asg_id" {
  description = "App autoscaling group"
  value       = module.compute.app_asg_id
}

output "web_lb_tg_arn" {
  description = "Web load balancer target group ARN"
  value       = module.loadbalancer.web_lb_tg_arn
}
output "app_lb_tg_arn" {
  description = "Web load balancer target group ARN"
  value       = module.loadbalancer.app_lb_tg_arn
}

output "database_endpoint" {
  description = "module database Database endpoint"
  value       = module.database.db_endpoint
}

output "web_lb_sg_id" {
  description = "webserver loadbalancer Sg"
  value       = module.security.web_lb_sg_id
}

output "app_lb_sg_id" {
  description = "application_server loadbalancer sg"
  value       = module.security.app_lb_sg_id
}

output "s3_bucket" {
  description = "S3 bucket name"
  value       = module.s3_bucket.s3_bucket
}
output "s3_env_bucket" {
  description = "environment s3 bucket name"
  value       = module.s3_bucket.s3_env_bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_bucket.s3_bucket_arn
}
output "s3_env_bucket_arn" {
  value = module.s3_bucket.s3_env_bucket_arn
}

output "cw_log_arn" {
  description = "CloudWatch log ARN"
  value       = module.cloudwatch.cw_log_arn
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.ec2_instance_id
}
output "ec2_publicip" {
  description = "EC2 instance public IP"
  value       = module.ec2.ec2_publicip
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = module.sns.sns_topic_arn
}
