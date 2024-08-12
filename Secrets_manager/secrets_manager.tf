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

resource "aws_secretsmanager_secret" "name" {

    name = "demo_secret"
    description = "This is the demo secret"
    recovery_window_in_days = 7

    generate_secret_string {
    password_length = 16
    include_space   = false
  }
}


resource "aws_lambda_function" "name" {

    function_name = "function_for_secrets_manager"
    runtime = "python3.11"
    handler = "lambda_function.lambda_handler"
    role = "arn:aws:iam::010526262752:role/service-role/demo-role-d2rf3g05"
  
}

resource "aws_secretsmanager_secret_rotation" "name" {

    secret_id = aws_secretsmanager_secret.name.id
    rotation_lambda_arn = aws_lambda_function.name.arn

    rotation_rules {

        automatically_after_days = 30
      
    }
  
}