# ECS Fargate サービス
resource "aws_ecs_service" "app" {
  name            = "aws-task-management-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 0
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.app_private_1.id,
      aws_subnet.app_private_2.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "app"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_vpc_endpoint.ecr_api,
    aws_vpc_endpoint.ecr_dkr,
    aws_vpc_endpoint.ecs_logs,
    aws_vpc_endpoint.secretsmanager,
    aws_iam_role_policy.ecs_db_secret
  ]

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}