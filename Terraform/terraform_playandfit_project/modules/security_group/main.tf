resource "aws_security_group" "sg_db" {
  name = var.environment
  description = "SQL Database Security Group"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}_sg"
  }

  ingress  {
    from_port=3306
    to_port=3306
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  
  egress  {
    from_port=0
    to_port=0
    protocol=-1
    cidr_blocks=["0.0.0.0/0"]
  }
}