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
  #access_key = var.access_key
  #secret_key = var.secret_access_key

}

resource "aws_s3_bucket" "name" {

  bucket = "gvp-venkata-524"

}

resource "aws_s3_bucket_acl" "name" {

  acl = "private"
  bucket = aws_s3_bucket.name.id
  
}

resource "aws_s3_bucket_public_access_block" "name" {

  bucket = aws_s3_bucket.name.id

  block_public_acls = false
  ignore_public_acls = false
  block_public_policy = true
  restrict_public_buckets = true
  
}

resource "aws_s3_bucket_versioning" "name" {
  bucket = aws_s3_bucket.name.id

  versioning_configuration {
    status = "Enabled"
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

/*variable "access_key" {

  type = string
  sensitive = true
  
}

variable "secret_access_key" {

  sensitive = true
  type = string
  
}

*/

resource "aws_s3_bucket_lifecycle_configuration" "name" {

  bucket = aws_s3_bucket.name.id

  rule {
    id = "Starndard to Standard IA"
    status = "Enabled"

    transition {
      days = 30
      storage_class = "STANDARD-IA"
    }

    transition {
      days = 60
      storage_class = "GLACIER"
    }
  }
}