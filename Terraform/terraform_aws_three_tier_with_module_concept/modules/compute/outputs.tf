output "web_asg_id" {
  description = "ID of the web autoscaling group"
  value       = aws_autoscaling_group.web.id
}

output "app_asg_id" {
  description = "ID of the app autoscaling group"
  value       = aws_autoscaling_group.app.id
}
