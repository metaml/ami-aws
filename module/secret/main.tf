resource "aws_secretsmanager_secret" "openai-api-key-aip" {
  name = "openai-api-key"
  description = "openai api key for AIP"
}
