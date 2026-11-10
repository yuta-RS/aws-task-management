# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "aws-task-management-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "aws-task-management-public-rt"
  }
}

# Private Route Table
# S3 Gateway Endpointの関連付け対象
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "aws-task-management-private-rt"
  }
}

# Public Subnet 1
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Public Subnet 2
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Application Private Subnet 1
resource "aws_route_table_association" "app_private_1" {
  subnet_id      = aws_subnet.app_private_1.id
  route_table_id = aws_route_table.private.id
}

# Application Private Subnet 2
resource "aws_route_table_association" "app_private_2" {
  subnet_id      = aws_subnet.app_private_2.id
  route_table_id = aws_route_table.private.id
}