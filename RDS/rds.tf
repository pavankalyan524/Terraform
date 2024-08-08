terraform {
    required_version = ">=1.9.3"

    required_providers {
      aws = {

        source = "Hashicorp/aws"
        version = ">=3.0.0"
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


resource "aws_subnet" "One" {

    vpc_id = aws_vpc.name.id
    cidr_block = "10.1.0.0/24"
    availability_zone = "ap-south-2a"

  
}

resource "aws_subnet" "Two" {

    vpc_id = aws_vpc.name.id
    cidr_block = "10.2.0.0/24"
    availability_zone = "ap-south-2b"

}

resource "aws_db_subnet_group" "name" {

    subnet_ids = [ aws_subnet.One.id , aws_subnet.Two.id ]
  
}

resource "aws_security_group" "name" {

    description = "Security Group for RDS"

    vpc_id = aws_vpc.name.id

    ingress {

        from_port = "3306"
        to_port = "3306"
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

resource "aws_db_parameter_group" "name" {

    name = "parametergroupofsql"
    family = "mysql 8.0"
    
    parameter {
      name = "max_connections"
      value = "1000"
    }
    
    parameter {
      name = "slow_query_log"
      value = "1"
    }

    parameter {
      name = "long_query_time"
      value = "2"
    }

    parameter {
      name = "performance_schema"
      value = "1"
    }
}



resource "aws_db_instance" "name" {

    engine = "mysql"
    engine_version = "8.0"
    identifier = "automated"
    username = "admin"
    password = "admin@524"
    storage_type = "gp2"
    storage_encrypted = true
    allocated_storage = "100"
    instance_class = "db.t3.micro"
    publicly_accessible = false
    
    backup_retention_period = 7
    backup_window = "03:00-04:00"
    maintenance_window = "sun:03:00-sun:04:00"

    final_snapshot_identifier = "final-snapshot"
    skip_final_snapshot = false
    deletion_protection = true
    multi_az = true
    max_allocated_storage = "1000"

    performance_insights_enabled = true
    performance_insights_retention_period = 7
    
    parameter_group_name = aws_db_parameter_group.name.id
    db_subnet_group_name = aws_db_subnet_group.name.id
    vpc_security_group_ids = [aws_security_group.name.id]
    monitoring_interval = 60
    
  
}