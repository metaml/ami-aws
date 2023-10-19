terraform {
  cloud {
    organization = "Karmanplus"
    workspaces { name = "babel-aws" }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }

  required_version = ">= 1.6.1"
}
