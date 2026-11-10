# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "aws-task-management-alb-sg"
  description = "Security group for task management ALB"
  vpc_id      = aws_vpc.main.id
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "aws-task-management-rds-sg"
  description = "Security group for task management RDS"
  vpc_id      = aws_vpc.main.id
}

# Internet -> ALB HTTP 80
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP traffic from the Internet"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

# ALB -> ECS FastAPI 8000
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id = aws_security_group.alb.id

  description                  = "Allow HTTP traffic from ALB to ECS"
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
  referenced_security_group_id = aws_security_group.ecs.id
}