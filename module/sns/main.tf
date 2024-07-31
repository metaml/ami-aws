resource "aws_sns_topic" "aip" {
  name = var.sns_name
}

resource "aws_sns_topic_policy" "aip-policy" {
  arn = aws_sns_topic.aip.arn
  policy = data.aws_iam_policy_document.aip-policy-doc.json
}

data "aws_iam_policy_document" "aip-policy-doc" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.aip.arn,
    ]

    sid = "__default_statement_ID"
  }
}