provider "aws" {
  region = "us-east-2"
}

module "bucket" {
  source = "./module/bucket"
}

module "ecr" {
  source = "./module/ecr"
}

module "log" {
  source = "./module/log"
}

module "lambda" {
  source = "./module/lambda"
}

module "secret" {
  source = "./module/secret"
}

module "opensearch" {
  source = "./module/opensearch"
}
