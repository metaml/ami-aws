resource "aws_s3_bucket" "babel" {
  bucket = var.bucket

  tags = {
    Name        = "babel"
    Environment = "production"
  }
}

resource "aws_s3_bucket_ownership_controls" "babel" {
  bucket = aws_s3_bucket.babel.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
