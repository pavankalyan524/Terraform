terraform {
  required_version = ">=1.9"
  required_providers {
    aws = {
        version = ">=3.0"
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {

    region = "ap-south-2"
}

resource "aws_lambda_function" "name" {

    function_name = "Demo_function"
    role = "arn:aws:iam::010526262752:role/service-role/demo-role-d2rf3g05"
    handler = "lambda_function.lambda_handler"
    runtime = "python 3.0"

    s3_bucket = "pavankalyan524"
    s3_key = ""

    environment {

      variables = {

        NAME = "pavan"
      }
    }
}


