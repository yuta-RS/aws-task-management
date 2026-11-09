# ECS Fargate用セキュリティグループ
resource "aws_security_group" "ecs" {
  name        = "aws-task-management-ecs-sg"
  description = "Security group for ECS Fargate"
  vpc_id      = aws_vpc.main.id
}

# ALBからECSのFastAPIへ
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id = aws_security_group.ecs.id

  description                  = "Allow FastAPI from ALB"
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
  referenced_security_group_id = aws_security_group.alb.id
}

# ECSからRDSへ
resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id = aws_security_group.rds.id

  description                  = "Allow PostgreSQL from ECS"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.ecs.id
}

# VPCエンドポイント用セキュリティグループ
resource "aws_security_group" "ecs_endpoints" {
  name        = "aws-task-management-ecs-endpoints-sg"
  description = "HTTPS endpoints for ECS Fargate"
  vpc_id      = aws_vpc.main.id
}

# ECSからVPCエンドポイントへHTTPS通信
resource "aws_vpc_security_group_ingress_rule" "endpoints_from_ecs" {
  security_group_id = aws_security_group.ecs_endpoints.id

  description                  = "Allow HTTPS from ECS"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.ecs.id
}
# ECS -> VPCエンドポイント（HTTPS）
resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  security_group_id = aws_security_group.ecs.id

  description = "Allow HTTPS from ECS"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

# ECS -> RDS（PostgreSQL）
resource "aws_vpc_security_group_egress_rule" "ecs_postgres" {
  security_group_id = aws_security_group.ecs.id

  description                  = "Allow PostgreSQL to RDS"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.rds.id
}