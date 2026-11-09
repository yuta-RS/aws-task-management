resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]
}

resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = aws_subnet.app_private_1.id
  preserve_client_ip = false

  security_group_ids = [
    aws_security_group.eice.id
  ]

  tags = {
    Name = "aws-task-management-eice"
  }
}