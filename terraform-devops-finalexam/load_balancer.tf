resource "aws_lb" "app_alb" {
  name               = "finalexam-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.main_a.id, aws_subnet.main_b.id]

  tags = {
    Name = "finalexam-alb"
  }
}

resource "aws_lb_target_group" "prod_tg" {
  name        = "finalexam-prod-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "finalexam-prod-tg"
  }
}

resource "aws_lb_target_group_attachment" "prod1" {
  target_group_arn = aws_lb_target_group.prod_tg.arn
  target_id        = aws_instance.prod_env1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "prod2" {
  target_group_arn = aws_lb_target_group.prod_tg.arn
  target_id        = aws_instance.prod_env2.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg.arn
  }
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}
