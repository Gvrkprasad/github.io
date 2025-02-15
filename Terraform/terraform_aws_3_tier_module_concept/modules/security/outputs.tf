output "web_lb_sg" {
  description = "web_loadbalancer_sg"
  value = aws_security_group.web.id
}

output "web_instance_sg" {
  description = "public_insance_sg"
  value = aws_security_group.public_instance.id
    
}

output "app_lb_sg" {
  description = "app_loadbalancer_sg"
  value = aws_security_group.app.id
}

output "app_instance_sg" {
  description = "private_instance_sg"
  value = aws_security_group.private_instance.id
}

output "db_sg_id" {
  description = "database_sg"
  value = aws_security_group.database.id
}