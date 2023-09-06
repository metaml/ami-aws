variable "region" {
  description = "aws region"
  default     = "us-east-2"
}

variable "bucket" {
  description = "s3 bucket name"
  default     = "babel-karmanplus-us-east-2"
}

variable "acl" {
  description = "ACL for s3 bucket"
  default     = "private"
}
