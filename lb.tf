# Application Load Balancer
resource "aws_lb" "k8s_alb" {
  name               = "k8s-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "k8s-alb"
  }
}
resource "aws_lb_target_group" "k8s_tg" {
  name        = "k8s-target-group"
  port        = 30000 # NodePort range or specific port (adjust based on your k8s Service)
  protocol    = "HTTP"
  vpc_id      = aws_vpc.demo_vpc.id
  target_type = "instance"

  health_check {
    path                = "/health" # Adjust based on your app's health check endpoint
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "k8s-target-group"
  }
}

# Register EC2 worker nodes with the Target Group
resource "aws_lb_target_group_attachment" "k8s_tg_attachment" {
  count            = local.worker_nodes_count
  target_group_arn = aws_lb_target_group.k8s_tg.arn
  target_id        = aws_instance.worker_nodes[count.index].id
  port             = 30000 # Match the target group port
}

resource "aws_lb_listener" "k8s_listener" {
  load_balancer_arn = aws_lb.k8s_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_tg.arn
  }
}
