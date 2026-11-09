resource "aws_iam_role" "ec2" {
  name        = "aws-task-management-ec2-role"
  description = "IAM role for EC2 Systems Manager access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "aws-task-management-ec2-role"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "deployment_package" {
  name = "AllowReadDeploymentPackage"
  role = aws_iam_role.ec2.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = [
          "arn:aws:s3:::aws-task-management-deploy-yk001/packages.zip",
          "arn:aws:s3:::aws-task-management-deploy-yk001/pip-package.zip",
          "arn:aws:s3:::aws-task-management-deploy-yk001/pip-package-old.zip",
          "arn:aws:s3:::aws-task-management-deploy-yk001/extra-packages.zip",
          "arn:aws:s3:::aws-task-management-deploy-yk001/psycopg2_binary-2.9.12-cp39-cp39-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        ]
      }
    ]
  })
}