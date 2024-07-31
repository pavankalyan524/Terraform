provider "aws" {
  region = "ap-south-2"
}

resource "aws_vpc" "demo" {
  cidr_block = "10.100.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "HYD VPC"
  }
}

resource "aws_subnet" "demo"{
    cidr_block = "10.100.1.0/24"
    vpc_id = aws_vpc.demo.id
    availability_zone = "ap-south-2a"

    tags = {
        name = "HYD SUBNET"
    }
}


data "aws_ami" "demo"{

    most_recent = true
    owners = ["amazon"]

    filter {
        name  = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_key_pair" "demo"{
    key_name = "demo_key_pair"
    public_key = file("~/.ssh/id_rsa.pub")

}


resource "aws_security_group" "demo" {

    name = "Demo"
    description = "This is demo"
    vpc_id = aws_vpc.demo.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

resource "aws_instance" "demo"{
    ami = data.aws_ami.demo.id
    key_name = aws_key_pair.demo.key_name
    instance_type = "t3.micro"
    subnet_id = aws_subnet.demo.id
    availability_zone = "ap-south-2a"
    associate_public_ip_address = true
    security_groups = [aws_security_group.demo.id]

    root_block_device {
      volume_size= 8
      volume_type = "gp3"
      delete_on_termination = true

    }
}

resource "aws_route_table" "demo"{
        vpc_id = aws_vpc.demo.id

        tags = {
            name = "Public hyd route table"
        }
}


resource "aws_route" "demo"{
        route_table_id = aws_route_table.demo.id
        destination_cidr_block  = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo.id
}

resource "aws_route_table_association" "demo"{
        subnet_id = aws_subnet.demo.id
        route_table_id = aws_route_table.demo.id

}

resource "aws_internet_gateway" "demo"{
        vpc_id = aws_vpc.demo.id

        tags = {
            name ="Demo Internet gateway"
        }
}
  

resource "aws_vpn_gateway" "demo" {

    vpc_id = aws_vpc.demo.id

    tags = {
        name = "HYD VPG GATEWAY........"
    }
  
}

resource "aws_customer_gateway" "demo" {

    bgp_asn = 65317
    ip_address = "13.201.61.204"
    type = "ipsec.1"

    tags = {

        name = "StrongSwan Gateway..."
    }
}

