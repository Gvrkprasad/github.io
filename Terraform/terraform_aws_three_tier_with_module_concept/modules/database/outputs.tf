output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_subnet_group" {
  description = "Database subnet group"
  value       = aws_db_subnet_group.main.name
}
