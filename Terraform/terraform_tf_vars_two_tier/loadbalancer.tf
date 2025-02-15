
# Application Load Balancer
resource "aws_lb" "glps_alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.glps_alb_sg.id]
  subnets            = aws_subnet.glps_subnet[*].id

}

# target group
resource "aws_lb_target_group" "glps_tg" {
  name     = "glps-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.glps_vpc.id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 4
        interval            = 10
    }
}

# listener for target group
resource "aws_lb_listener" "glps_listener" {
  load_balancer_arn = aws_lb.glps_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.glps_tg.arn
  }
}

