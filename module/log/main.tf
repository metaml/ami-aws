resource "aws_cloudwatch_log_group" "babel" {
  count = var.create ? 1 : 0
  name = var.name
  # name and name_prefix can conflict
  # name_prefix = var.name_prefix
  retention_in_days = var.retention_in_days
  kms_key_id  = var.kms_key_id
  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "babel" {
  count = var.create ? 1 : 0
  name           = "babel"
  log_group_name = aws_cloudwatch_log_group.babel[0].name
  depends_on = [aws_cloudwatch_log_group.babel]
}
