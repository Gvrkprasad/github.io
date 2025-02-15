output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}
output "web_lb_sg" {
  description = "web_loadbalancer_sg"
  value       = module.security.web_lb_sg
}
output "app_lb_sg" {
  description = "app_loadbalancer_sg"
  value       = module.security.app_lb_sg
}
output "web_instance_sg" {
  description = "web_instance_sg"
  value = module.security.web_instance_sg
}
output "app_instance_sg" {
  description = "app_instance_sg"
  value = module.security.app_instance_sg
}

output "web_subnet_ids" {
  description = "webserver subnet ids"
  value = module.vpc.web_subnet_ids
}
output "app_subnet_ids" {
  description = "webserver subnet ids"
  value = module.vpc.app_subnet_ids
}

output "web_tg_alb_arn" {
  description = "loadbalancer webserver target group arn"
  value = module.loadbalancer.web_tg_alb_arn
}
output "app_tg_alb_arn" {
  description = "loadbalancer appserver target group arn"
  value = module.loadbalancer.app_tg_alb_arn
}

output "database_subnet_ids" {
  description = "database subnet ids"
  value = module.vpc.database_subnet_ids
}
output "db_sg_id" {
  description = "Database Sg ID"
  value = module.security.db_sg_id
}