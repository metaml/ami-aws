variable "tags" {
  description = "a map of tags to add to the babel lambda function"
  type        = map(string)
  default     = {
    Name = "babel"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:karmanplus/babel-aws"
  }
}
