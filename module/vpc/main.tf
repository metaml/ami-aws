data "aws_vpc" "default" { default = true }
data "aws_internet_gateway" "default" { internet_gateway_id = "igw-01f3d9294d50a2c5e" }
data "aws_subnet" "default-a" { id = "subnet-05413c6d31d066a8c" }
data "aws_subnet" "default-b" { id = "subnet-09b373b677dc9a809" }
data "aws_subnet" "default-c" { id = "subnet-01536c0d51454e3ad" }

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
