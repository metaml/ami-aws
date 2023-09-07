resource "aws_s3_bucket" "babel" {
  bucket = var.bucket

  tags = {
    Name = "babel"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:karmanplus/babel-aws"
  }
}

resource "aws_s3_bucket_ownership_controls" "babel" {
  bucket = aws_s3_bucket.babel.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
