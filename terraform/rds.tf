resource "aws_db_subnet_group" "main" {
  name        = "aws-task-management-db-subnet-group"
  description = "Subnet group for task management RDS"

  subnet_ids = [
    aws_subnet.db_private_1.id,
    aws_subnet.db_private_2.id
  ]
}

resource "aws_db_instance" "main" {
  identifier = "aws-task-management-db"

  engine         = "postgres"
  engine_version = "18.3"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  username = "postgres"
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = false
  publicly_accessible = false

  backup_retention_period = 1
  copy_tags_to_snapshot   = true

  auto_minor_version_upgrade = true
  deletion_protection        = false

  performance_insights_enabled = true
  monitoring_interval          = 0

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  skip_final_snapshot = true

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}