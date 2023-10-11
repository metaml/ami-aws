# retrieves the default vpc for this region
data "aws_vpc" "default" {
  default = true
}

# retrieves the subnet ids in the default vpc
data "aws_subnet_ids" "default_subnets" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "babel" {
  name   = "batch"
  vpc_id = data.aws_vpc.default.id
  description = "batch VPC security group"
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

# batch Service Role
resource "aws_iam_role" "babel-batch" {
  name = "babel-batch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
      "Service": "batch.amazonaws.com"
    }
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "babel" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# ecs task execution role
resource "aws_iam_role" "babel" {
  name = "babel"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "babel-execution" {
  role       = aws_iam_role.aws_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
