provider "aws" {
  region = "us-east-2"
}

module "bucket" {
  source = "./module/bucket"
}

module "ec2" {
  source = "./module/ec2"
}

module "ecr" {
  source = "./module/ecr"
}

module "lambda" {
  source = "./module/lambda"
}

module "log" {
  source = "./module/log"
}

module "rds" {
  source = "./module/rds"
}

module "secret" {
  source = "./module/secret"
}

module "sns" {
  source = "./module/sns"
}

module "tls" {
  source = "./module/tls"
}

module "vpc" {
  source = "./module/vpc"
}
