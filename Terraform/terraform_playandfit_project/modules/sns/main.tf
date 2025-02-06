resource "aws_sns_topic" "sns" {
  name = var.environment
}   
resource "aws_sns_topic_subscription" "sns" {
  topic_arn = aws_sns_topic.sns.arn
  protocol = "email-json"
  endpoint = var.sns_endpoint1
}
resource "aws_sns_topic_subscription" "sns2" {
  topic_arn = aws_sns_topic.sns.arn
  protocol = "sms"
  endpoint = var.sns_endpoint2
}