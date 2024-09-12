data "aws_vpc" "default" {default = true}
data "aws_internet_gateway" "default" {internet_gateway_id = "igw-01f3d9294d50a2c5e"}
data "aws_subnet" "default-a" {id = "subnet-05413c6d31d066a8c"}
data "aws_subnet" "default-b" {id = "subnet-09b373b677dc9a809"}
data "aws_subnet" "default-c" {id = "subnet-01536c0d51454e3ad"}

resource "aws_security_group" "aip-rest" {
  name = "aip-rest"
  description = "aip-rest (ec2) security group"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["50.68.120.205/32", data.aws_vpc.default.cidr_block]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0", data.aws_vpc.default.cidr_block]
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0", data.aws_vpc.default.cidr_block]
  }
}

resource "aws_route_table" "aip" {
  vpc_id = data.aws_vpc.default.id
  route {
    gateway_id = data.aws_internet_gateway.default.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "public route table"
  }
}

resource "aws_route_table_association" "default-a" {
  subnet_id      = data.aws_subnet.default-a.id
  route_table_id = aws_route_table.aip.id
}

resource "aws_route_table_association" "default-b" {
  subnet_id      = data.aws_subnet.default-b.id
  route_table_id = aws_route_table.aip.id
}

resource "aws_route_table_association" "default-c" {
  subnet_id      = data.aws_subnet.default-c.id
  route_table_id = aws_route_table.aip.id
}
