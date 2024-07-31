provider "aws" {

    region = "ap-south-2"  
}

resource "aws_efs_file_system" "demo" {

    creation_token = "PAVAN_EFS"
  
    encrypted = true

    lifecycle_policy {
      transition_to_ia = "AFTER_30_DAYS"

    }   

    tags = {
      "name" = "PAVAN_EFS"
    }
}

resource "aws_vpc" "demo" {

    cidr_block = "10.250.0.0/16"

    instance_tenancy = "default"
}

resource "aws_subnet" "one" {

    cidr_block = "10.250.1.0/24"
    availability_zone = "ap-south-2a"
    vpc_id = aws_vpc.demo.id
    map_public_ip_on_launch = true
}

resource "aws_subnet" "two" {

    cidr_block = "10.250.1.0/24"
    availability_zone = "ap-south-2b"
    vpc_id = aws_vpc.demo.id
    map_public_ip_on_launch = true
}

resource "aws_security_group" "demo" {
    
    vpc_id = aws_vpc.demo.id
    name = "SG-GROUP"

    ingress {

        from_port = "2049"
        to_port = "2049"
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    egress {

        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]

    }
}

resource "aws_efs_mount_target" "demo" {

    file_system_id = aws_efs_file_system.demo.id
    subnet_id = aws_subnet.one.id
    security_groups = [aws_security_group.demo.id]

}
