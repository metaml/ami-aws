resource "aws_secretsmanager_secret" "babel-github" {
  name = "github-api-token"
}

resource "aws_secretsmanager_secret" "babel-slack" {
  name = "slack-api-token"
}

output "babel-github" {
  value = "${aws_secretsmanager_secret.babel-github.arn}"
}

output "babel-slack" {
  value = "${aws_secretsmanager_secret.babel-slack.arn}"
}
