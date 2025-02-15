output "aws_autoscaling_group_web_asg" {
  value = aws_autoscaling_group.web_asg.id
}

output "aws_autoscaling_group_app_asg" {
  value = aws_autoscaling_group.app_asg.id
}

output "aws_launch_template_app" {
  value = aws_launch_template.app.id
}

output "aws_launch_template_web" {
  value = aws_launch_template.web.id
}

