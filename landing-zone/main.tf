terraform {
  required_version = ">= 1.10.0"
  backend "s3" {
    bucket       = "aws-cloud-security-tf-faizal"
    key          = "landing-zone/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}