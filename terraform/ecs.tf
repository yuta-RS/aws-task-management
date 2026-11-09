# ECSクラスター
resource "aws_ecs_cluster" "app" {
  name = "aws-task-management-cluster"
}

# Fargate用ターゲットグループ
resource "aws_lb_target_group" "ecs" {
  name        = "aws-task-management-ecs-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = "/health"
    matcher             = "200"
  }
}