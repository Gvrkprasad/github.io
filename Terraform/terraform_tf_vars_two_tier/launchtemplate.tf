
# launch template
resource "aws_launch_template" "glps_lc" {
    name_prefix = "${var.env}-lc"
    image_id = var.ami_id
    instance_type = var.instance_type
    
    key_name = var.key_name

    user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              echo "Hello from the application server" > /var/www/html/index.html
              sudo systemctl enable apache2
              EOF
  )

    lifecycle {
        create_before_destroy = true
    }
}

# autoscaling group
resource "aws_autoscaling_group" "glps_asg" {
    name = "${var.env}-asg"
    
    launch_template {
        id = aws_launch_template.glps_lc.id
        version = "$Latest"
    }
    min_size = 1
    max_size = 3
    desired_capacity = 2
    vpc_zone_identifier = aws_subnet.glps_subnet[*].id
    target_group_arns = [aws_lb_target_group.glps_tg.arn]
    health_check_type = "ELB"
    health_check_grace_period = 300
    termination_policies = ["OldestInstance"]
    tag {
        key = "Name"
        value = "${var.env}-asg"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_attachment" "glps_asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.glps_asg.name
    alb_target_group_arn = aws_lb_target_group.glps_tg.arn
    }