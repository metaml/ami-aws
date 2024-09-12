data "aws_vpc" "default" {
  default = true
}

data "aws_secretsmanager_secret" "db-password" {
  name = "db-password"
}

data "aws_secretsmanager_secret_version" "db-password" {
  secret_id = data.aws_secretsmanager_secret.db-password.id
}

data "aws_secretsmanager_secret" "db-user" {
  name = "db-user"
}

data "aws_secretsmanager_secret_version" "db-user" {
  secret_id = data.aws_secretsmanager_secret.db-user.id
}

resource "random_string" "password" {
  length  = 64
  upper   = true
  numeric = true
  special = false
}

resource "aws_security_group" "rds" {
  vpc_id      = data.aws_vpc.default.id
  name        = "aip"
  description = "allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [ "50.68.120.205/32",  data.aws_vpc.default.cidr_block ]
  }
}

resource "aws_iam_role" "aip" {
  name = "aip"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "rds-monitoring-attachment" {
  name = "rds-monitoring-attachment"
  roles = [aws_iam_role.aip.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# "password" is fetched and within the Makefile from AWS secrets manager
resource "aws_db_instance" "aip" {
  identifier             = "aip"
  db_name                = "aip"
  instance_class         = "db.t3.small"
  allocated_storage      = 8
  storage_encrypted      = true
  engine                 = "postgres"
  engine_version         = "16.3"
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  username               = data.aws_secretsmanager_secret_version.db-user.secret_string
  password               = data.aws_secretsmanager_secret_version.db-password.secret_string
  skip_final_snapshot    = true

  monitoring_interval = 60 # Interval in seconds (minimum 60 seconds)
  monitoring_role_arn = aws_iam_role.aip.arn

  performance_insights_enabled = true

  tags = {
    Name = "aip"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:recomune/aip-aws"
  }
}
