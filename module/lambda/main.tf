data "archive_file" "sns2s3" {  
  type = "zip"  
  source_file = "${path.root}/src/sns2s3/sns2s3.py" 
  output_path = "sns2s3.zip"
}

data "archive_file" "s32rds" {  
  type = "zip"  
  source_file = "${path.root}/src/s32rds/s32rds.py" 
  output_path = "s32rds.zip"
}

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

resource "aws_iam_role" "aip" {
  name   = "aip-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "aip" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSLambdaExecute",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ])
  role       = "${aws_iam_role.aip.name}"
  policy_arn = each.value
}

### sns to s3

resource "aws_lambda_function" "sns2s3" {
  function_name    = "sns2s3"
  filename         = "sns2s3.zip"
  source_code_hash = data.archive_file.sns2s3.output_base64sha256
  runtime          = "python3.11"  
  handler          = "sns2s3.handler"  
  timeout          = 900 # seconds
  role             = aws_iam_role.aip.arn
}

resource "aws_lambda_permission" "sns2s3" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns2s3.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = "arn:aws:sns:us-east-2:975050288432:aip"
}

resource "aws_sns_topic_subscription" "sns2s3" {
  topic_arn = "arn:aws:sns:us-east-2:975050288432:aip"
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns2s3.arn

  depends_on = [aws_lambda_permission.sns2s3]
}

### s3 to rds (postgresql)

resource "aws_lambda_function" "s32rds" {
  function_name    = "s32rds"
  filename         = "s32rds.zip"
  source_code_hash = data.archive_file.s32rds.output_base64sha256
  runtime          = "python3.11"  
  handler          = "s32rds.handler"  
  timeout          = 900 # seconds
  role             = aws_iam_role.aip.arn
}

resource "aws_lambda_permission" "s32rds" {
  statement_id = "AllowS3Invoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s32rds.function_name
  principal  = "s3.amazonaws.com"
  source_arn = "arn:aws:s3:::aip-recomune-us-east-2"
}

resource "aws_s3_bucket_notification" "s32rds" {
  bucket = "aip-recomune-us-east-2"
  lambda_function {
    lambda_function_arn = aws_lambda_function.s32rds.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = null
    filter_suffix       = null
  }

  depends_on = [aws_lambda_permission.s32rds]
}

###

output "sns2s3-arn" {
  value = "${aws_lambda_function.sns2s3.arn}"
}

output "s32rds-arn" {
  value = "${aws_lambda_function.s32rds.arn}"
}
