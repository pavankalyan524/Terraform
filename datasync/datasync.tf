terraform {
  required_version = ">=1.9"
  required_providers {
    aws = {
        version = ">=3.0"
        source = "Hashicorp/aws"
    }
  }
}

provider "aws" {

    region = "ap-south-2"
}

resource "aws_vpc" "demo" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true

}

resource "aws_subnet" "demo" {

    vpc_id = aws_vpc.demo.id
    availability_zone = "ap-south-2a"
    cidr_block = "10.1.0.0/24"
    map_public_ip_on_launch = true
  
}

resource "aws_vpc_endpoint" "demo" {

    vpc_endpoint_type = "gateway"
    vpc_id = aws_vpc.demo.id
    service_name = "com.amazonaws.ap-south2-s3"
    route_table_ids = aws_vpc.demo.route_table_id
}

resource "aws_datasync_agent" "name" {
    activation_key = ""
    ip_address = ""
    vpc_endpoint_id = aws_vpc_endpoint.demo.id
    security_group_arns = [aws_security_group.arn]
}

resource "aws_datasync_location_nfs" "name" {

    server_hostname = ""
    subdirectory = "/mnt/data/"
    on_prem_config {
      agent_arns = [aws_datasync_agent.name.arn]
    }
}

resource "aws_datasync_location_s3" "name" {

    s3_bucket_arn = "arn:aws:ap-south-2:s3"
    subdirectory = "/path/to/bucket/"

    s3_config {
      bucket_access_role_arn = aws_iam_role.name.id
    }
}

resource "aws_datasync_task" "name" {

    source_location_arn = aws_datasync_location_nfs.name.arn
    destination_location_arn = aws_datasync_location_s3.name.arn

    cloudwatch_log_group_arn = "arn:aws:ap-south-2:cloudwatch:loggroup"

    options {
      
      overwrite_mode = "ALWAYS"
      verify_mode = "ONLY_FILES_TRANSFERRED"
      atime = "PRESERVE"
      mtime = "PRESERVE"
      uid = "PRESERVE"
      gid = "PRESERVE"
      posix_permissions = "PRESERVE"
      preserve_deleted_files = "PRESERVE"
      preserve_devices = "PRESERVE"
      bytes_per_second = -1

    }
  
}




