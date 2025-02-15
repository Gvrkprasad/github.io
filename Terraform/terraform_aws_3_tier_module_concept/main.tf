module "compute" {
  source = "./modules/compute"
  environment = var.environment
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  web_instance_sg = module.security.web_instance_sg
  app_instance_sg = module.security.app_instance_sg
  desired_capacity_web_asg = var.desired_capacity_web_asg
  max_size_web_asg = var.max_size_web_asg
  min_size_web_asg = var.min_size_web_asg
  desired_capacity_app_asg = var.desired_capacity_app_asg
  max_size_app_asg = var.max_size_app_asg
  min_size_app_asg = var.min_size_app_asg
  web_subnet_ids = module.vpc.web_subnet_ids
  app_subnet_ids = module.vpc.app_subnet_ids
  web_tg_alb_arn = module.loadbalancer.web_tg_alb_arn
  app_tg_alb_arn = module.loadbalancer.app_tg_alb_arn
}

module "database" {
  source = "./modules/database"
  environment = var.environment
  database_subnet_ids = module.vpc.database_subnet_ids
  identifier = var.identifier
  storage = var.storage
  storage_type = var.storage_type
  instance_class = var.instance_class
  engine = var.engine
  engine_version = var.engine_version
  db_name = var.db_name
  username = var.username
  password = var.password
  db_sg_id = module.security.db_sg_id
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  environment = var.environment
  web_subnet_ids = module.vpc.web_subnet_ids
  web_lb_sg = module.security.web_lb_sg
  app_lb_sg = module.security.app_lb_sg
  app_subnet_ids = module.vpc.app_subnet_ids
  vpc_id = module.vpc.vpc_id
}

module "security" {
  source = "./modules/security"
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  
}

module "vpc" {
  source = "./modules/vpc"
  environment = var.environment
  cidr_block = var.cidr_block
  
}




