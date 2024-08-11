terraform {
  required_version = ">=1.9"

  required_providers {
    aws = {
        version = ">=1.9"
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
    region = "ap-south-2"
}


resource "aws_lambda_function" "name" {

    function_name = "eventrule_test"
    runtime = "python3.11"
    role = "arn:aws:iam::010526262752:role/service-role/demo-role-d2rf3g05"
    handler = "lambda_function.lambda_handler"

    s3_bucket = "pavankalyan524"
    s3_key = "lambda_function.zip"

}

resource "aws_cloudwatch_event_rule" "name" {

    name = "testing_rule"
    event_bus_name = "default"
    event_pattern = jsonencode({

        "source" : ["aws.s3"],
        "detail-type" : ["AWS API Call via CloudTrail"],
        "detail" : {
            "eventSource" : ["s3.amazonaws.com"],
            "eventName" : ["PutObject"],
            "requesParameters" : {
                "bucketName" : ["pavan524"]
            }
        }
    })
  
}

resource "aws_cloudwatch_event_target" "name" {

    rule = aws_cloudwatch_event_rule.name.name
    target_id = "Invoke lambda"
    arn = aws_lambda_function.name.arn
}

resource "aws_lambda_permission" "name" {

    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.name.arn
    function_name = aws_lambda_function.name.function_name
    action = "lambda:InvokeFunction"
    statement_id = "GivingPermissiontoEventbridgefrom lambda"
  
}

