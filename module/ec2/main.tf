data "aws_vpc" "default" {default = true}

data "aws_secretsmanager_secret" "key-public" {
  name = "key-public"
}

data "aws_secretsmanager_secret_version" "key-public" {
  secret_id = data.aws_secretsmanager_secret.key-public.id
}

data "aws_secretsmanager_secret" "key-private" {
  name = "key-private"
}

data "aws_secretsmanager_secret_version" "key-private" {
  secret_id = data.aws_secretsmanager_secret.key-private.id
}

resource "aws_security_group" "aip-rest" {
  name = "aip-rest"
  description = "aip-rest (ec2) security group"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["50.68.120.205/32"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "aip-rest" {
  ami                         = "ami-0f381b685ecd8406c"
  instance_type               = "t2.small"
  key_name                    = "key-pair"
  security_groups             = [aws_security_group.aip-rest.name]
  associate_public_ip_address = true
  
  tags = {
    Name = "aip-rest"
  }
}
