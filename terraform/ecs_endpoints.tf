# ECSがECRの認証APIへアクセスするためのエンドポイント
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.app_private_1.id,
    aws_subnet.app_private_2.id
  ]

  security_group_ids = [
    aws_security_group.ecs_endpoints.id
  ]

  tags = {
    Name = "aws-task-management-ecr-api"
  }
}

# ECSがECRのDockerイメージを取得するためのエンドポイント
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.app_private_1.id,
    aws_subnet.app_private_2.id
  ]

  security_group_ids = [
    aws_security_group.ecs_endpoints.id
  ]

  tags = {
    Name = "aws-task-management-ecr-dkr"
  }
}

# ECSがCloudWatch Logsにログを送信するためのエンドポイント
resource "aws_vpc_endpoint" "ecs_logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.app_private_1.id,
    aws_subnet.app_private_2.id
  ]

  security_group_ids = [
    aws_security_group.ecs_endpoints.id
  ]

  tags = {
    Name = "aws-task-management-ecs-logs"
  }
}
# ECSがSecrets ManagerからDBパスワードを取得するためのエンドポイント
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.app_private_1.id,
    aws_subnet.app_private_2.id
  ]

  security_group_ids = [
    aws_security_group.ecs_endpoints.id
  ]

  tags = {
    Name = "aws-task-management-secretsmanager"
  }
}