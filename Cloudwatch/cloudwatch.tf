terraform {
  required_version = ">=1.9.3"
  required_providers {
    aws = {
        source = "haschicorp/aws"
        version = ">=3.0.0"
    }
  }
}

provider "aws" {

    region = "ap-south-2"
}

resource "aws_sns_topic" "name" {

    name = "Demo topic"
  
}

resource "aws_sns_topic_subscription" "name" {

    topic_arn = aws_sns_topic.topic_arn
    protocol = "email"
    endpoint = "gvpk1999@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "name" {

    alarm_name = "Cpu_utilization"
    alarm_description = "This is for high cpu utilization"

    metric_name = "CPUUtilization"
    namespace =  "AWS/EC2"
    treshhold = "5"
    comparison_operator = "GreaterThanEqualToTreshhold"
    period = "300"
    evaluation_periods = "1"
    alarm_actions = [aws_sns_topic.name.arn]
    ok_actions = [aws_sns_topic.name.arn]
    insufficient_data_actions = [aws_sns_topic.name.arn]
    statistic "Average"

    dimenstions = {
        instanceId = "i-0fba9ab4c4050f548"
    }

  
}