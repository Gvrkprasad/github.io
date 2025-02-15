# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.database_subnet_ids
  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "db_instance" {
  identifier           = var.identifier
  allocated_storage    = var.storage
  storage_type         = var.storage_type
  instance_class       = var.instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  db_name              = var.db_name
  username             = var.username
  password             = var.password # Change this in production
  skip_final_snapshot  = true

  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.environment}-db_instance"
  }
}