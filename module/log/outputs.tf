output "cloudwatch_log_group_name" {
  description = "Name of Cloudwatch log group"
  value       = try(aws_cloudwatch_log_group.analytics[0].name, "")
}

output "cloudwatch_log_group_arn" {
  description = "ARN of Cloudwatch log group"
  value       = try(aws_cloudwatch_log_group.analytics[0].arn, "")
}

# output "cloudwatch_log_group_name" {
#   description = "Name of Cloudwatch log group"
#   value       = try(aws_cloudwatch_log_group.s32rds[0].name, "")
# }

# output "cloudwatch_log_group_arn" {
#   description = "ARN of Cloudwatch log group"
#   value       = try(aws_cloudwatch_log_group.s32rds[0].arn, "")
# }

# output "cloudwatch_log_group_name" {
#   description = "Name of Cloudwatch log group"
#   value       = try(aws_cloudwatch_log_group.sns2s3[0].name, "")
# }

# output "cloudwatch_log_group_arn" {
#   description = "ARN of Cloudwatch log group"
#   value       = try(aws_cloudwatch_log_group.sns2s3[0].arn, "")
# }
