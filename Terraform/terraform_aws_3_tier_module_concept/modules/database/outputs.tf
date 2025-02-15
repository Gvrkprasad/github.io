output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.db_instance.endpoint
}

output "db_instance_id" {
    description = "Database instance id"
    value       = aws_db_instance.db_instance.id
}

output "aws_db_subnet_group" {
    description = "Database subnet group"
    value       = aws_db_subnet_group.main.id
  
}

