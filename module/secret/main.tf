resource "aws_secretsmanager_secret" "babel-github-token" {
  name = "github-token"
}

resource "aws_secretsmanager_secret" "babel-slack-token" {
  name = "slack-token"
}

output "babel-github-token" {
  value = "${aws_secretsmanager_secret.babel-github-token.arn}"
}

output "babel-slack-token" {
  value = "${aws_secretsmanager_secret.babel-slack-token.arn}"
}
