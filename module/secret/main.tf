resource "aws_secretsmanager_secret" "babel-slack" {
  name = "slack-api-token"
}

resource "aws_secretsmanager_secret" "babel-github" {
  name = "github-api-token"
}

output "arn" {
  value = "${aws_secretsmanager_secret.babel-slack.arn}"
}

output "arn" {
  value = "${aws_secretsmanager_secret.babel-github.arn}"
}
