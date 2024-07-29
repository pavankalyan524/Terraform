provider "aws" {
  region = "ap-south-2"
}

resource "aws_vpc" "demo" {
  cidr_block       = "10.100.0.0/16"
  instance_tenancy = "dedicated"
}

resource "aws_subnet" "demo" {
  cidr_block        = "10.100.1.0/24"
  vpc_id            = aws_vpc.demo.id
  availability_zone = "ap-south-2a"
}

