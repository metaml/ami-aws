data "aws_vpc" "default" { default = true }
data "aws_subnet" "default" { id = "subnet-05413c6d31d066a8c" }
data "aws_key_pair" "key-pair" { key_name = "key-pair" }
data "aws_secretsmanager_secret" "key-public" { name = "key-public" }
data "aws_secretsmanager_secret_version" "key-public" { secret_id = data.aws_secretsmanager_secret.key-public.id }
data "aws_secretsmanager_secret" "key-private" { name = "key-private" }
data "aws_secretsmanager_secret_version" "key-private" { secret_id = data.aws_secretsmanager_secret.key-private.id }

resource "aws_network_interface" "aip" {
  subnet_id       = data.aws_subnet.default.id
  security_groups = [ aws_security_group.ec2.id ]
}

resource "aws_security_group" "ec2" {
  name = "ec2"
  description = "aip-rest (ec2) security group"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "50.68.120.205/32", "67.87.6.71/32", "99.76.147.145/32", data.aws_vpc.default.cidr_block ]
  }
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = [ "50.68.120.205/32", "67.87.6.71/32", "99.76.147.145/32", data.aws_vpc.default.cidr_block ]
  }
  ingress {
    from_port = 8283
    to_port = 8283
    protocol = "tcp"
    cidr_blocks = [ "50.68.120.205/32", "67.87.6.71/32", "99.76.147.145/32", data.aws_vpc.default.cidr_block ]
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# ami-0f381b685ecd8406c nixos
# ami-09efc42336106d2f2 al2023
resource "aws_instance" "ec2" {
  ami                         = "ami-0f381b685ecd8406c"
  instance_type               = "t3.medium"
  key_name                    = "key-pair"
  subnet_id                   = data.aws_subnet.default.id
  # NB: -  don't use security_groups, it will destroy your instance
  #        on every terraform apply
  #     - use vpc_security_group_ids instead
  # security_groups             = [data.aws_security_group.aip-rest.id]
  vpc_security_group_ids      = [ aws_security_group.ec2.id ]
  associate_public_ip_address = true
  root_block_device {
    volume_size           = 32
    encrypted             = true
    delete_on_termination = false
  }
  lifecycle {
    ignore_changes = [
      volume_tags,
    ]
  }
  user_data            = file("${path.module}/configuration.nix.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  depends_on           = [data.aws_key_pair.key-pair]
  tags = {
    name = "ami-0"
  }
}

resource "aws_eip" "ec2" {
  instance = aws_instance.ec2.id
  domain   = "vpc"
  tags = {
    name = "aip-rest"
  }
}

resource "aws_eip_association" "ec2" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.ec2.id
}

resource "aws_iam_role" "ec2" {
  name = "ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
	    "ec2.amazonaws.com",
	    "iam.amazonaws.com",
	    "ssm.amazonaws.com",
	    "sso.amazonaws.com"
	  ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    name = "aip-rest"
  }
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2"
  role = aws_iam_role.ec2.name
  tags = {
    name = "aip-rest"
  }
}

# "ssm:AmazonSSMManagedInstanceCore"
resource "aws_iam_policy" "ec2" {
  name = "ec2"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
	  "ecr:*",
	  "iam:ReadOnlyAccess",
	  "lambda:UpdateFunctionCode",
	  "rds:FullAccess",
	  "s3:FullAccess",
	  "s3:ListAllMyBuckets",
	  "secretsmanager:GetSecretValue",
	  "secretsmanager:ReadWrite",
	  "sns:ListSubscriptions",
	  "sns:ListTopics",
	  "sns:Publish",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
	  "ssm:DescribeAssociation",
          "ssm:DescribeDocument",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:PutInventory",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ]
        Resource = "*"
      },
      {
	"Effect": "Allow",
	"Action": [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
	],
	"Resource": "*"
      },
      {
	"Effect": "Allow",
	"Action": [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
      ],
      "Resource": "*"
      }
    ]
  })
  tags = {
    name = "aip-rest"
  }
}

# resource "aws_iam_role" "ssm" {
#   name = "ssm"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ssm.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ssm" {
#   role = aws_iam_role.ec2.name
#   policy_arn = aws_iam_policy.ssm.arn
# }

# resource "aws_iam_instance_profile" "ssm" {
#   name = "ssm"
#   role = aws_iam_role.ssm.name
# }

# resource "aws_iam_policy" "ssm" {
#   name = "ssm"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
# 	  "ssm:AmazonSSMManagedInstanceCore"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
