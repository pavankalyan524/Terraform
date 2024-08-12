terraform {
  required_version = ">=1.9"
  required_providers {
    aws = {
        version = ">=4.0"
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {

    region = "ap-south-2"
  
}

resource "random_password" "name" {

    length = 16
    numeric = true
    special = true
    
}

resource "aws_secretsmanager_secret" "name" {

    name = "demo_secret"
    description = "This is the demo secret"
    recovery_window_in_days = 7

    /*generate_secret_string {
    password_length = 16
    include_space   = false
  }*/
}

resource "aws_secretsmanager_secret_version" "name" {

    secret_id = aws_secretsmanager_secret.name.id
    secret_string = jsonencode({

        "username" : "admin"
        "password" : "random_password.name.result"
    })

    
  
}


resource "aws_lambda_function" "name" {

    function_name = "function_for_secrets_manager"
    runtime = "python3.11"
    handler = "lambda_function.lambda_handler"
    role = "arn:aws:iam::010526262752:role/service-role/demo-role-d2rf3g05"

    s3_bucket = "pavankalyan524"
    s3_key = "lambda-function.zip"

  
}

resource "aws_secretsmanager_secret_rotation" "name" {

    secret_id = aws_secretsmanager_secret.name.id
    rotation_lambda_arn = aws_lambda_function.name.arn

    rotation_rules {

        automatically_after_days = 30
      
    }
  
}