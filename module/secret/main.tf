resource "aws_secretsmanager_secret" "babel" {
  name = "slack-api-token"
}

output "arn" {
  value = "${aws_secretsmanager_secret.babel.arn}"
}
