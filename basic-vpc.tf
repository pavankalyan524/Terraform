provider "aws"
{
    region = "ap-south-2"
}

resource "aws_vpc" {
    cidr_block = "10.100.0.0/16"
    instance_tenancy = "Dedicated"
}