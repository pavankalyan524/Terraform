provider "aws"{
    region = "ap-south-2"
}

resource "aws_vpc" "demo" {

    cidr_block = "10.100.0.0/16"
    instance_tenancy = "default"
  
}

resource "aws_subnet" "one" {
    vpc_id = aws_vpc.demo.id
    availability_zone = "ap-south-2a"
    map_public_ip_on_launch = true
    cidr_block = "10.100.1.0/24"
  
}

resource "aws_subnet" "two" {

    vpc_id = aws_vpc.demo.id
    availability_zone = "ap-south-2b"
    map_public_ip_on_launch = true
    cidr_block = "10.100.2.0/24"
  
}


resource "aws_efs_file_system" "demo" {

    creation_token = "DEMO"
    encrypted = true
    lifecycle_policy {
     transition_to_ia = "AFTER_30_DAYS"
    }  
}

resource "aws-security_group" "for-instance"{
    name = "DEMO2"
    description = "2nd Demo "
    vpc_id = aws_vpc.demo.id 

    ingress  {
        from_port = "2049"
        to_port = "2049"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress  {
        from_port = "22"
        to_port = "22"
        protocol = "ssh"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
resource "aws_security_group" "for-efs" {
    name = "DEMO"
    description = "DEMO"
    vpc_id = aws_vpc.demo.id

    ingress {

        from_port = "2049"
        to_port = "2049"
        protocol = "tcp"
        security_groups = [aws_security_group.for-instance.id]
    }

    egress {

        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }


  
}
resource "aws_efs_mount_target" "demo" {

    subnet_id = aws_subnet.one.id
    security_groups = [aws_security_group.for-efs.id]
    file_system_id = aws_efs_file_system.demo.id
  
}

resource "aws_efs_mount_target" "demo2" {

    subnet_id = aws_subnet.two.id
    security_groups = [aws_security_group.for-efs.id]
    file_system_id = aws_efs_file_system.demo.id
  
}

resource "aws_internet_gateway" "igw" {

    vpc_id = aws_vpc.demo.id
  
}
resource "aws_route_table" "demo" {
    vpc_id = aws_vpc.demo.id

    route {

        cidr_block = ["0.0.0.0/0"]
        gateway_id = aws_internet_gateway.igw

    }
  
}

resource "aws_route_table_association" "demo" {

    subnet_id = aws_subnet.one
    
    route_table_id = aws_route_table.demo.id
}

resource "aws_key_pair" "demo" {

    key_name = "DEMO KEY"

    public_key = file("~/.ssh/id_rsa.pub")
  
}

data "aws_ami" "name" {

    most_recent = true
    owners = ["amazon"]

    filter {
      
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      
    } 
}

resource "aws_instance" "demo" {

    ami = data.aws_ami.name.id
    instance_type = "t3.micro"
    key_name = aws_key_pair.demo.id
    subnet_id = aws_subnet.one.id
    security_groups = [aws_security_group.for-instance.id]
    availability_zone = "ap-south-2a"
    associate_public_ip_address = true

    user_data = <<-EOF
                    #!/bin/bash
                    sudo yum update -y
                    sudo install nfs-utils -y
                    mkdir -p /mnt/efs
                    echo "fs-$(aws_efs_file_system.id).efs.ap-south-2.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0 " >> /etc/fstab
                EOF 

}

