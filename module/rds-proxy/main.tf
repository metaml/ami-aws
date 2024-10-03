data "aws_vpc" "default" { default = true }
data "aws_subnet" "default-a" { id = "subnet-05413c6d31d066a8c" }
data "aws_subnet" "default-b" { id = "subnet-09b373b677dc9a809" }
data "aws_subnet" "default-c" { id = "subnet-01536c0d51454e3ad" }
data "aws_secretsmanager_secret" "db-password" { name = "db-password" }
data "aws_secretsmanager_secret" "db-user"     { name = "db-user" }
data "aws_secretsmanager_secret_version" "db-password" { secret_id = data.aws_secretsmanager_secret.db-password.id }
data "aws_secretsmanager_secret_version" "db-user"     { secret_id = data.aws_secretsmanager_secret.db-user.id }

resource aws_iam_policy rds-proxy {
  name = "ami"
  policy = jsonencode({
    "Version": "2012-10-17",
      "Statement": [{
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = [ aws_secretsmanager_secret.db-user.arn,
	             aws_secretsmanager_secret.db-password.arn,
	           ]
      },
      {
        Effect = "Allow"
        Action = "kms:Decrypt"
        Resource = aws_kms_key.secret_key.arn
        Condition = {
          "StringEquals": { "kms:ViaService": "secretsmanager.ap-northeast-2.amazonaws.com" }
        }
      }]
  })
}

resource aws_iam_role rds-proxy {
  name = "ami"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = ["rds.amazonaws.com"]
      }
    }]
  })
}

resource aws_iam_role_policy_attachment rds-proxy {
  role       = aws_iam_role.rds_proxy.name
  policy_arn = aws_iam_policy.rds_proxy.arn
}

resource aws_db_proxy rds-proxy {
  name                   = "ami"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 900
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = var.security_group_ids
  vpc_subnet_ids         = var.subnet_ids
  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.rds_secret.arn
  }
}

resource aws_db_proxy_endpoint reader {
  db_proxy_name          = aws_db_proxy.rds_proxy.name
  db_proxy_endpoint_name = "${aws_db_proxy.rds_proxy.name}-reader"
  vpc_subnet_ids         = var.subnet_ids
  target_role            = "READ_ONLY"
  tags = local.module_tags
}

resource aws_db_proxy_default_target_group rds_proxy {
  db_proxy_name = aws_db_proxy.rds_proxy.name
  connection_pool_config {
    connection_borrow_timeout = 120
    max_connections_percent   = 100
    session_pinning_filters   = []
  }
}

resource aws_db_proxy_target rds_proxy {
  db_cluster_identifier = data.aws_rds_cluster.cluster.id
  db_proxy_name         = aws_db_proxy.rds_proxy.name
  target_group_name     = aws_db_proxy_default_target_group.rds_proxy.name
}

# resource "aws_db_proxy" "ami" {
#   name = "ami"
#   engine_family = "POSTGRESQL"
#   idle_client_timeout = 900
#   require_tls = true
#   role_arn = "arn:aws:iam::0000000000:role/RdsProxyRole"
#   vpc_security_group_ids = ["sg-0000000000abcdef"]
#   vpc_subnet_ids = [ data.aws_subnet.default-a, data.aws_subnet.default-b, data.aws_subnet.default-c ]

#   auth {
#     auth_scheme = "SECRETS"
#     iam_auth = "DISABLED"
#     secret_arn = "arn:aws:secretsmanager:us-east-1:0000000000:secret:rds-secrets-arn"
#   }
# }
