resource "aws_alb" "frontend" {
  name               = "dev-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dev_security_group.id]
  subnets            = [aws_subnet.public_subnet.id]

  enable_deletion_protection = true

  tags = {
    Name = "my-frontend-alb"
  }
}

resource "aws_alb_listener" "frontend" {
  load_balancer_arn = aws_alb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.frontend.arn
  }
}

resource "aws_alb_target_group" "frontend" {
  name     = "frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

# Network Load Balancers
resource "aws_lb" "nlb" {
  name               = "dev-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet.id]

  enable_deletion_protection = true

  tags = {
    Name = "dev-nlb"
  }
}

resource "aws_lb_listener" "frontend_tcp" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

resource "aws_lb_target_group" "backend" {
  name     = "backend"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.dev_vpc.id

  health_check {
    interval            = 30
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
  }
}
