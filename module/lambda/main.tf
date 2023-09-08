data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "babel" {
  name   = "babel-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "babel" {
  function_name = "babel"
  timeout       = 7 # seconds
  image_uri     = "621458661507.dkr.ecr.us-east-2.amazonaws.com/babel:latest"
  package_type  = "Image"

  role = aws_iam_role.babel.arn

  environment {
    variables = {
      Name = "babel"
      Terraform = "true"
      Environment = "production"
      CreatedBy = "github:karmanplus/babel-aws"
   }
  }
}

resource "aws_lambda_permission" "babel" {
  statement_id = "AllowS3Invoke"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.babel.function_name}"
  principal  = "s3.amazonaws.com"
  source_arn = "arn:aws:s3:::babel-karmanplus-us-east-2"
}

resource "aws_s3_bucket_notification" "babel" {
  bucket = "babel-karmanplus-us-east-2"
  lambda_function {
    lambda_function_arn = aws_lambda_function.babel.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = null
    filter_suffix       = null
  }

  depends_on = [aws_lambda_permission.babel]
}

output "arn" {
  value = "${aws_lambda_function.babel.arn}"
}
