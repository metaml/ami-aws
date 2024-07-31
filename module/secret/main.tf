resource "aws_secretsmanager_secret" "openai-api-key" {
  name = "openai-api-key"
  description = "openai api key for AIP"
}

resource "aws_secretsmanager_secret" "db-user" {
  name = "db-user"
  description = "db user"
}

resource "aws_secretsmanager_secret" "db-password" {
  name = "db-password"
  description = "db password"
}
