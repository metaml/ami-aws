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

module "secret" {
  source = "./module/secret"
}
