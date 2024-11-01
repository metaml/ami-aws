data "aws_vpc" "default" { default = true }
data "aws_subnet" "default-a" { id = "subnet-05413c6d31d066a8c" }
data "aws_subnet" "default-b" { id = "subnet-09b373b677dc9a809" }
data "aws_subnet" "default-c" { id = "subnet-01536c0d51454e3ad" }
data "aws_instance" "ec2" {
  filter {
    name  = "tag:name"
    values = [ "ami-0" ]
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "allow incoming HTTPS connections"
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [ "50.68.120.205/32", "67.87.6.71/32", "99.76.147.145/32", data.aws_vpc.default.cidr_block ]
  }
  ingress {
    from_port   = 8283
    to_port     = 8283
    protocol    = "tcp"
    cidr_blocks = [ "50.68.120.205/32", "67.87.6.71/32", "99.76.147.145/32", data.aws_vpc.default.cidr_block ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "network"
  # note: http/https lb below vs. a network lb above
  # load_balancer_type = "application"
  security_groups    = [ aws_security_group.https.id ]
  subnets = [
    data.aws_subnet.default-a.id,
    data.aws_subnet.default-b.id,
    data.aws_subnet.default-c.id,
  ]
  tags = {
    name = "alb"
  }
  depends_on = [ data.aws_instance.ec2 ]
}

resource "aws_lb_target_group" "ami" {
  name         = "ami"
  port         = 8000
  protocol     = "TCP"
  # protocol     = "HTTPS"    # load_balancer_type = "application"
  target_type  = "instance"
  vpc_id = data.aws_vpc.default.id
  health_check {
    interval            = 8
    path                = "/ping"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "listener-8000" {
  load_balancer_arn = aws_lb.alb.id
  port              = 8000
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.ami.arn
    type             = "forward"
  }
  depends_on = [ aws_lb_target_group.ami ]
}

resource "aws_lb_listener" "listener-8283" {
  load_balancer_arn = aws_lb.alb.id
  port              = 8283
  protocol          = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.ami.arn
    type             = "forward"
  }
  depends_on = [ aws_lb_target_group.ami ]
}

resource "aws_lb_target_group_attachment" "ami" {
  count            = 1
  target_group_arn = aws_lb_target_group.ami.arn
  target_id        = data.aws_instance.ec2.id
}
