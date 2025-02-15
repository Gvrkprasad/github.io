resource "aws_cloudwatch_log_group" "web" {
    name = "${var.environment}_web_cw"
    retention_in_days = 30   # incase if not mention Retention:Never Expire
}
