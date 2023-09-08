provider "aws" {
  region = "us-east-2"
}

module "bucket" {
  source = "./module/bucket"
}

module "ecr" {
  source = "./module/ecr"
}

module "log-group" {
  source = "./module/log-group"
}

module "log-stream" {
  source = "./module/log-stream"
}

# module "lambda" {
#   source = "./module/lambda"
# }
