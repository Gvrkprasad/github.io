output "sns_topic" {
    value = aws_sns_topic.s3_object_sns.name
}
output "sns_topic_arn" {
  value = aws_sns_topic.s3_object_sns.arn
}
