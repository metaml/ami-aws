resource "aws_cloudwatch_event_rule" "every-hour" {
  name        = "once-an-hour"
  description = "trigger lambda once an hour"

  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "github" {
  rule      = aws_cloudwatch_event_rule.once-an-hour
  target_id = "trigger-lambda-github"
  arn       = aws_lambda_function.github
}

resource "aws_cloudwatch_event_target" "slack" {
  rule      = aws_cloudwatch_event_rule.once-an-hour
  target_id = "trigger-lambda-slack"
  arn       = aws_lambda_function.slack
}
