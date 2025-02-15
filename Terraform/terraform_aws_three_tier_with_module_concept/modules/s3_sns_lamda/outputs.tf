output "sns_topic_arn" {
  value = aws_sns_topic_subscription.sns_lamda.arn
}