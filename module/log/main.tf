resource "aws_cloudwatch_log_group" "analytics" {
  count = 1
  name = "/aws/lambda/analytics"
  # name and name_prefix can conflict
  # name_prefix = var.name_prefix
  retention_in_days = var.retention_in_days
  kms_key_id  = var.kms_key_id
}

resource "aws_cloudwatch_log_stream" "analytics" {
  count = var.create ? 1 : 0
  name           = "analytics"
  log_group_name = aws_cloudwatch_log_group.analytics[0].name
  depends_on = [aws_cloudwatch_log_group.analytics]
}

resource "aws_cloudwatch_log_group" "s32rds" {
  count = 1
  name = "/aws/lambda/s32rds"
  # name and name_prefix can conflict
  # name_prefix = var.name_prefix
  retention_in_days = var.retention_in_days
  kms_key_id  = var.kms_key_id
}

resource "aws_cloudwatch_log_stream" "s32rds" {
  count = var.create ? 1 : 0
  name           = "s32rds"
  log_group_name = aws_cloudwatch_log_group.s32rds[0].name
  depends_on = [aws_cloudwatch_log_group.s32rds]
}

resource "aws_cloudwatch_log_group" "sns2s3" {
  count = 1
  name = "/aws/lambda/sns2s3"
  # name and name_prefix can conflict
  # name_prefix = var.name_prefix
  retention_in_days = var.retention_in_days
  kms_key_id  = var.kms_key_id
}

resource "aws_cloudwatch_log_stream" "sns2s3" {
  count = var.create ? 1 : 0
  name           = "sns2s3"
  log_group_name = aws_cloudwatch_log_group.sns2s3[0].name
  depends_on = [aws_cloudwatch_log_group.sns2s3]
}
