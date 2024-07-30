resource "aws_s3_bucket" "aip" {
  bucket = var.bucket

  tags = {
    Name = "aip"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:recomune/aip-aws"
  }
}

resource "aws_s3_bucket_ownership_controls" "aip" {
  bucket = aws_s3_bucket.aip.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

output "id" {
  description = "the ID of the bucket"
  value       = aws_s3_bucket.aip.id
}

output "arn" {
  description = "the ARN of the bucket--format arn:aws:s3:::bucketname"
  value       = aws_s3_bucket.aip.arn
}
