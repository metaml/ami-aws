provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

resource "random_string" "password" {
  length  = 64
  upper   = true
  numeric = true
  special = false
}

resource "aws_security_group" "babel" {
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "babel"
  description = "Allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "babel" {
  name = "babel"
  assume_role_policy = jsonencode({
  Version = "2012-10-17",
  Statement = [
    {
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "rds-monitoring-attachment" {
  name = "rds-monitoring-attachment"
  roles = [aws_iam_role.babel.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "babel" {
  identifier             = "babel"
  db_name                = "babel"
  instance_class         = "db.t2.large"
  allocated_storage      = 256
  storage_encrypted      = true
  engine                 = "postgres"
  engine_version         = "15.3"
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.babel.id]
  username               = "babel"
  password               = "random_string.password.result}"
  skip_final_snapshot    = true

  monitoring_interval = 60 # Interval in seconds (minimum 60 seconds)
  monitoring_role_arn = aws_iam_role.babel.arn

  performance_insights_enabled = true

  tags = {
    Name = "babel"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:karmanplus/babel-aws"
  }
}
