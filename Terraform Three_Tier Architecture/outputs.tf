output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app.dns_name
}

output "alb_web_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.web.dns_name
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}