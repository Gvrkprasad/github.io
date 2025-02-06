resource "aws_db_instance" "sql" {
  allocated_storage    = var.db_storage
  db_name              = var.db_name
  engine               = var.db_engine
  engine_version       = var.db_version
  instance_class       = var.db_instance_type
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.subnet_db.name
  vpc_security_group_ids = [var.db_sgid]
  publicly_accessible = true
  skip_final_snapshot  = true
}

resource "aws_db_subnet_group" "subnet_db"{
 name = ("${var.environment}_db_subnet")
 subnet_ids = var.subnet_id
}

/*
resource "null_resource" "initialize_db" {
  triggers = {
    rds_id = aws_db_instance.sql.id
  }
  
  provisioner "local-exec" {
    command = <<EOT
     mysql -h ${resource.aws_db_instance.sql.address} -u ${var.db_username}
      -p'${var.db_password}' -D ${var.db_name} < create_tables.sql
    EOT
  }
}
*/
