output "web_lb_sg_id" {
  value = aws_security_group.web_lb.id
}

output "app_lb_sg_id" {
  value = aws_security_group.app_lb.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}
