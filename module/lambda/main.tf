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

resource "aws_iam_role_policy_attachment" "babel" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AWSLambdaExecute",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ])
  role       = "${aws_iam_role.babel.name}"
  policy_arn = each.value
}

resource "aws_lambda_function" "babel" {
  function_name = "babel"
  timeout       = 900 # seconds
  image_uri     = "621458661507.dkr.ecr.us-east-2.amazonaws.com/babel:latest"
  package_type  = "Image"
  role = aws_iam_role.babel.arn

  image_config {
    entry_point = ["/bin/babel"]
  }

  environment {
    variables = {
      Name = "babel"
      Terraform = "true"
      Environment = "production"
      CreatedBy = "github:karmanplus/babel-aws"
   }
  }
}

resource "aws_lambda_function" "github" {
  function_name = "github"
  timeout       = 900 # seconds
  image_uri     = "621458661507.dkr.ecr.us-east-2.amazonaws.com/babel:latest"
  package_type  = "Image"
  role = aws_iam_role.babel.arn

  image_config {
    entry_point = ["/bin/github"]
  }

  environment {
    variables = {
      Name = "github"
      Terraform = "true"
      Environment = "production"
      CreatedBy = "github:karmanplus/babel-aws"
   }
  }
}

resource "aws_lambda_function" "slack" {
  function_name = "slack"
  timeout       = 900 # seconds
  image_uri     = "621458661507.dkr.ecr.us-east-2.amazonaws.com/babel:latest"
  package_type  = "Image"
  role = aws_iam_role.babel.arn

  image_config {
    entry_point = ["/bin/slack"]
  }

  environment {
    variables = {
      Name = "slack"
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
    lambda_function_arn = "${aws_lambda_function.babel.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = null
    filter_suffix       = null
  }

  depends_on = [aws_lambda_permission.babel]
}

output "arn" {
  value = "${aws_lambda_function.babel.arn}"
}
