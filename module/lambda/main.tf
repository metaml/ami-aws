data "aws_caller_identity" "current" {}

resource "aws_iam_role" "babel" {
  name   = "babel-lambda-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_iam_policy" "babel" {
  name         = "babel-lambda-policy"
  path         = "/"
  description  = "IAM policy for AWS lambda babel"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Actions": [
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "babel" {
  role        = aws_iam_role.babel.name
  policy_arn  = aws_iam_policy.babel.arn
}

resource "aws_lambda_function" "babel" {
  function_name = "babel"
  timeout       = 7 # seconds
  image_uri     = "621458661507.dkr.ecr.us-east-2.amazonaws.com/babel:latest"
  package_type  = "Image"

  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSRoleForLambda"

  environment {
    variables = {
      Name = "babel"
      Terraform = "true"
      Environment = "production"
      CreatedBy = "github:karmanplus/babel-aws"
   }
  }
}

resource "aws_s3_bucket_notification" "babel" {
  bucket = "babel"
  lambda_function {
    lambda_function_arn = aws_lambda_function.babel.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "file-prefix"
    filter_suffix       = "file-extension"
  }
}

resource "aws_lambda_permission" "babel" {
  statement_id = "AllowS3Invoke"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.babel.function_name}"
  principal  = "s3.amazonaws.com"
  source_arn = "arn:aws:s3:::babel"
}

output "arn" {
  value = "${aws_lambda_function.babel.arn}"
}
