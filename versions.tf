terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
  }

  required_version = ">= 1.9"
}
