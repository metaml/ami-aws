resource "aws_secretsmanager_secret" "babel-github-token" {
  name = "github-token"
  description = "babel access token to github/karman+"
}

resource "aws_secretsmanager_secret" "babel-sedaro-token" {
  name = "sedaro-token"
  description = "babel token for sedaro/karman+"
}

resource "aws_secretsmanager_secret" "babel-slack-token" {
  name = "slack-token"
  description = "babel token for slack/karman+"
}

output "babel-github-token" {
  value = "${aws_secretsmanager_secret.babel-github-token.arn}"
}

output "babel-sedaro-token" {
  value = "${aws_secretsmanager_secret.babel-sedaro-token.arn}"
}

output "babel-slack-token" {
  value = "${aws_secretsmanager_secret.babel-slack-token.arn}"
}
