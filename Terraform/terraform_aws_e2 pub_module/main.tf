module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "aws_ec2_tf_module_instance"

  instance_type          = "t2.micro"
  key_name               = "glpsk370-ubuntu.pem"
  monitoring             = true
  vpc_security_group_ids = ["sg-0f021c7ba29f79bc1"]
  subnet_id              = "subnet-00aac1fb23d337937"

  tags = {
    Terraform   = "true"
    Environment = "glps"
  }
}