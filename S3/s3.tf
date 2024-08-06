terraform {
  required_version = ">=1.9.3"
  required_providers {
    aws = {
      version = ">=3.0.0"
      source = "Hashicorp/aws"
    }
  }
}

provider "aws" {

  region = "ap-south-2"

}

resource "aws_s3_bucket" "name" {

  bucket = "GVP-524"

}

resource "aws_s3_bucket_acl" "name" {

  acl = private
  bucket = aws_s3_bucket.name.id
  
}

resource "aws_s3_bucket_public_access_block" "name" {

  bucket = aws_s3_bucket.name.id

  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  
}

resource "aws_s3_bucket_versioning" "name" {
  bucket = aws_s3_bucket.name.id

  versioning_configuration {
    status = enabled
  }
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {

  bucket = aws_s3_bucket.name.id

  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
}