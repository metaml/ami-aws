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

module "rds" {
  source = "./module/rds"
}

module "secret" {
  source = "./module/secret"
}

module "sns" {
  source = "./module/sns"
}
