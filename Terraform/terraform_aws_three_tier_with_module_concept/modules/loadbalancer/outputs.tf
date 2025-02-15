output "web_lb_dns" {
  description = "DNS name of the public load balancer"
  value       = aws_lb.public.dns_name
}

output "app_lb_dns" {
  description = "DNS name of the private load balancer"
  value       = aws_lb.private.dns_name
}

output "web_lb_tg_arn" {
  description = "ARN of the target group for the public load balancer"
  value       = aws_lb_target_group.web.arn
}

output "app_lb_tg_arn" {
  description = "ARN of the target group for the public load balancer"
  value       = aws_lb_target_group.app.arn
}