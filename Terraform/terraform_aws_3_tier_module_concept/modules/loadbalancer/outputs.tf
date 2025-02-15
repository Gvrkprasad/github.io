output "alb_web_dns_name" {
  value = aws_lb.web.dns_name
}

output "alb_app_dns_name" {
  value = aws_lb.app.dns_name
}

output "alb_web_arn" {
  value = aws_lb.web.arn
}

output "alb_app_arn" {
  value = aws_lb.app.arn
}

output "web_tg_alb_arn" {
  value = aws_lb_target_group.web_tg.arn
}
output "app_tg_alb_arn" {
  value = aws_lb_target_group.app_tg.arn
}
