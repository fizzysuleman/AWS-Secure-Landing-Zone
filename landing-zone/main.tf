terraform {
  required_version = ">= 1.10.0"
  backend "s3" {
    bucket       = "aws-cloud-security-tf-faizal"
    key          = "landing-zone/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}


// s3 state bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "aws-cloud-security-tf-faizal"
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name        = "Terraform State"
    Environment = "Bootstrap"
    ManagedBy   = "Terraform"
    Project     = "Secure AWS Landing Zone"
  }
}

// bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

// server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// public accees block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
