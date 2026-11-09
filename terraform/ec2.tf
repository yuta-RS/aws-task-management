resource "aws_instance" "app" {
  ami           = "ami-06380d26ad7176f2c"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.app_private_1.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  key_name             = "aws-task-management-key"
  iam_instance_profile = aws_iam_instance_profile.ec2.name

  monitoring        = false
  source_dest_check = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    iops                  = 3000
    throughput            = 125
    encrypted             = false
    delete_on_termination = true
  }

  tags = {
    Name = "aws-task-management-ec2"
  }
}