output "rds_endpoint" {
    value = aws_db_instance.sql.address
  }

output "rds_arn" {
  value = aws_db_instance.sql.arn
} 