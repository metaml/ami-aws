data "aws_vpc" "default" {default = true}
data "aws_subnet" "default" {id = "subnet-05413c6d31d066a8c"}
data "aws_security_group" "aip-rest" {name = "aip-rest"}

data "aws_key_pair" "key-pair" {key_name = "key-pair"}

data "aws_secretsmanager_secret" "key-public" {name = "key-public"}
data "aws_secretsmanager_secret_version" "key-public" {secret_id = data.aws_secretsmanager_secret.key-public.id}

data "aws_secretsmanager_secret" "key-private" {name = "key-private"}
data "aws_secretsmanager_secret_version" "key-private" { secret_id = data.aws_secretsmanager_secret.key-private.id}

resource "aws_network_interface" "aip-rest" {
  subnet_id = data.aws_subnet.default.id
  security_groups = [data.aws_security_group.aip-rest.id]
}

resource "aws_instance" "aip-rest" {
  ami                         = "ami-0f381b685ecd8406c"
  instance_type               = "t2.medium"
  key_name                    = "key-pair"
  subnet_id                   = data.aws_subnet.default.id
  security_groups             = [data.aws_security_group.aip-rest.id]
  associate_public_ip_address = true
  
  tags = {
    Name = "aip-rest"
  }

  depends_on = [data.aws_key_pair.key-pair]
}

resource "aws_eip" "aip-rest" {
  instance = aws_instance.aip-rest.id
  domain   = "vpc"
  tags = {
    name = "aip-rest"
  }
}

resource "aws_eip_association" "aip" {
  instance_id   = aws_instance.aip-rest.id
  allocation_id = aws_eip.aip-rest.id
}

