data "aws_vpc" "default" {default = true}
data "aws_internet_gateway" "default" {internet_gateway_id = "igw-01f3d9294d50a2c5e"}
data "aws_subnet" "default-a" {id = "subnet-05413c6d31d066a8c"}
data "aws_subnet" "default-b" {id = "subnet-09b373b677dc9a809"}
data "aws_subnet" "default-c" {id = "subnet-01536c0d51454e3ad"}
data "aws_caller_identity" "current" {}
data "aws_ecr_repository" "aip-lambda" { name = "aip-lambda" }
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

resource "aws_security_group" "lambda" {
  name        = "lambda"
  vpc_id      = data.aws_vpc.default.id
  description = "allow all outbound"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ "0.0.0.0/0" ]
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
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
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
  function_name = "sns2s3"
  image_uri     = "${data.aws_ecr_repository.aip-lambda.repository_url}:latest"
  package_type  = "Image"
  role          = aws_iam_role.aip.arn
  timeout       = 900 # seconds
  image_config {
    command = ["sns2s3.handler"]
  }
  vpc_config {
    subnet_ids = [ data.aws_subnet.default-a.id,
                   data.aws_subnet.default-b.id,
                   data.aws_subnet.default-c.id,
                 ]
    security_group_ids = [ aws_security_group.lambda.id ]
  }
  environment {
    variables = {
      Name = "sns2s3"
      Terraform = "true"
      Environment = "production"
      CreatedBy = "github:reomune/aip-aws"
   }
  }
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
  function_name = "s32rds"
  image_uri     = "${data.aws_ecr_repository.aip-lambda.repository_url}:latest"
  package_type  = "Image"
  role          = aws_iam_role.aip.arn
  timeout       = 900 # seconds
  image_config {
    command = ["s32rds.handler"]
  }
  vpc_config {
    subnet_ids = [ data.aws_subnet.default-a.id,
                   data.aws_subnet.default-b.id,
                   data.aws_subnet.default-c.id,
                 ]
    security_group_ids = [ aws_security_group.lambda.id ]
  }
  environment {
    variables = {
      Name = "s32rds"
      Terraform = "true"
      Environment = "production"
      CreatedBy = "github:reomune/aip-aws"
   }
  }
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
