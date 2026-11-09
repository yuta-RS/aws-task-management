resource "aws_security_group" "alb" {
  name        = "aws-task-management-alb-sg"
  description = "Security group for task management ALB"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "ec2" {
  name        = "aws-task-management-ec2-sg"
  description = "Security group for task management EC2"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "rds" {
  name        = "aws-task-management-rds-sg"
  description = "Security group for task management RDS"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "logs_endpoint" {
  name        = "aws-task-management-logs-endpoint-sg"
  description = "Allow HTTPS from EC2 to CloudWatch Logs endpoint"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "eice" {
  name        = "aws-task-management-eice-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.main.id
}
# ALB: Internet -> HTTP 80
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP traffic from the Internet"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

# EC2: ALB -> FastAPI 8000
resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  security_group_id = aws_security_group.ec2.id

  description                  = "Allow FastAPI traffic from ALB"
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
  referenced_security_group_id = aws_security_group.alb.id
}

# EC2: EICE -> SSH 22
resource "aws_vpc_security_group_ingress_rule" "ec2_from_eice" {
  security_group_id = aws_security_group.ec2.id

  description                  = "Allow SSH from EC2 Instance Connect Endpoint"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.eice.id
}

# RDS: EC2 -> PostgreSQL 5432
resource "aws_vpc_security_group_ingress_rule" "rds_from_ec2" {
  security_group_id = aws_security_group.rds.id

  description                  = "Allow PostgreSQL traffic from EC2"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.ec2.id
}

# CloudWatch Logs Endpoint: EC2 -> HTTPS 443
resource "aws_vpc_security_group_ingress_rule" "logs_from_ec2" {
  security_group_id = aws_security_group.logs_endpoint.id

  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.ec2.id
}