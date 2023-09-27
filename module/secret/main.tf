resource "aws_secretsmanager_secret" "babel-github-token" {
  name = "github-token"
  description = "babel access token to github/Karmanplus"
}

resource "aws_secretsmanager_secret" "babel-slack-token" {
  name = "slack-token"
  description = "babel token for slack/Karman+"
}

output "babel-github-token" {
  value = "${aws_secretsmanager_secret.babel-github-token.arn}"
}

output "babel-slack-token" {
  value = "${aws_secretsmanager_secret.babel-slack-token.arn}"
}
