# GitHub Actions用OIDCプロバイダー
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# GitHub Actionsが引き受けるIAMロール
resource "aws_iam_role" "github_actions" {
  name = "aws-task-management-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:yuta-RS@329973296/aws-task-management@1372941981:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}