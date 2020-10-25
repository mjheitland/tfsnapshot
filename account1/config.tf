terraform {
  required_version = "~> 0.13"
  required_providers {
    aws = ">= 3.12.0"
  }
  # backend "s3" {
  #   key = "tfsnapshot.tfstate"
  # }
}

provider "aws" {
  region = var.region
  profile = "account1"
}
