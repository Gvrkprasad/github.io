# launch template and autoscaling groups

resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-lt"
  image_id      = var.ami  # ubuntu ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [var.web_instance_sg]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to Terraform</h1>" > /var/www/html/index.html
              EOF
  )

  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-web-instance"
    }
  }

  key_name = var.key_name
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = var.desired_capacity_web_asg
  max_size            = var.max_size_web_asg
  min_size            = var.min_size_web_asg
  target_group_arns   = [var.web_tg_alb_arn]
  vpc_zone_identifier = var.web_subnet_ids

  launch_template {
    name      = aws_launch_template.web.name
    version = aws_launch_template.web.latest_version
  }

  # Ensure ASG updates when LT changes
  depends_on = [aws_launch_template.web]
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app_lt"
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [var.app_instance_sg]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to Terraform</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-app-instance"
    }
  }

  key_name = var.key_name
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = var.desired_capacity_app_asg
  max_size           = var.max_size_app_asg
  min_size           = var.min_size_app_asg
  target_group_arns  = [var.app_tg_alb_arn]
  vpc_zone_identifier = var.app_subnet_ids

  launch_template {
    name     = aws_launch_template.app.name
    version = aws_launch_template.app.latest_version
  }

  # Ensure ASG updates when LT changes
  depends_on = [aws_launch_template.app]
}