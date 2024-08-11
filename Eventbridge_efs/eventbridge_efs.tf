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

resource "aws_vpc" "name" {

    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
  
}

resource "aws_subnet" "name" {

    availability_zone = "ap-south-2a"
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.name.id
    
  
}


resource "aws_security_group" "name" {

    name = "for_efs_eventbridge"
    
    vpc_id = aws_vpc.name.id

    ingress {

        from_port = "2049"
        to_port = "2049"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
resource "aws_efs_file_system" "name" {

    creation_token = "efs_for_lambda"
    #throughput_mode = "default"
    #performance_mode = "bursting"
    
}

resource "aws_efs_mount_target" "name" {

    subnet_id = aws_subnet.name.id
    security_groups = [aws_security_group.name.id]
    file_system_id = aws_efs_file_system.name.id
}


resource "aws_lambda_function" "name" {

    function_name = "for_efs"
    runtime = "python3.11"
    handler = "lambda_function.lambda_handler"
    role = "arn:aws:iam::010526262752:role/service-role/demo-role-d2rf3g05"

    s3_bucket = "pavan524"
    s3_key = "lambda-function.zip"

    file_system_config {

      arn = aws_efs_file_system.name.arn
      local_mount_path = "/mnt/efs"
    }

    vpc_config {
        subnet_ids = [aws_subnet.name.id]
        security_group_ids = [aws_security_group.name.id]
    }
}


resource "aws_cloudwatch_event_rule" "name" {

    name = "for_efs"
    event_bus_name = "default"

    schedule_expression = "rate(375 minutes)"

}


resource "aws_cloudwatch_event_target" "name" {

    rule = aws_cloudwatch_event_rule.name.name
    target_id = "Invoke_lambda_function"
    arn = aws_lambda_function.name.arn

  
}

resource "aws_lambda_permission" "name" {

    principal = "events.amazonaws.com"
    action = "lambda:InvokeFunction"
    source_arn = aws_cloudwatch_event_rule.name.arn
    statement_id = "permission_giving_for_eventbridge"
    function_name = aws_lambda_function.name.function_name
  
}














