provider "aws" {
  region = "us-east-2"
}

module "bucket" {
  source = "./module/bucket"
}
