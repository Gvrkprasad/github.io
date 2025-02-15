#Using Existing launch template
# data "aws_launch_template" "tf_module" { }

#Creating new "launch_template" resource
resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-lt"
  image_id      = var.web_ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.web_lb_sg_id]
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
}

#Creating new "launch_template" resource
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app-lt"
  image_id      = var.app_ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  network_interfaces {
    security_groups = [var.app_lb_sg_id]
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
}

resource "aws_autoscaling_group" "web" {
  launch_template {
   # attaching existing data "launch_template (tf_module)""
   # id      = data.aws_launch_template.tf_module.id   #(remove '#' comment key to use this)

   # attaching newely created resource "launch_template (web)"
    id = aws_launch_template.web.id  
    version = "$Latest"
  }

  min_size               = 2
  max_size               = 4
  desired_capacity       = var.web_desired_capacity
  vpc_zone_identifier    = var.public_subnet_ids
  health_check_grace_period = 300
  health_check_type      = "ELB"
  target_group_arns = [var.web_lb_tg_arn]

  tag {
    key                 = "Name"
    value               = "${var.environment}-ag_web"
    propagate_at_launch = false
  }

}

resource "aws_autoscaling_group" "app" {
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  min_size               = 2
  max_size               = 4
  desired_capacity       = var.app_desired_capacity
  vpc_zone_identifier    = var.private_subnet_ids
  health_check_grace_period = 300
  health_check_type      = "ELB"
  target_group_arns = [var.app_lb_tg_arn]

  tag {
      key = "Name"
      value = "${var.environment}-ag_app"
      propagate_at_launch = false
    }
}
