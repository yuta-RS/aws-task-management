# ECSタスク実行ロール
resource "aws_iam_role" "ecs_execution" {
  name = "aws-task-management-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ECRからのイメージ取得とCloudWatch Logsへの出力権限
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# ECSがSSM Parameter StoreからDBパスワードを取得する権限
resource "aws_iam_role_policy" "ecs_ssm_password" {
  name = "aws-task-management-ecs-ssm-password"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:ap-northeast-1:762843419519:parameter/task-management/db/password"
      }
    ]
  })
}