provider "aws" {
  region = "ap-south-2"
}

resource "aws_vpc" "demo" {
  cidr_block
<<<<<<< HEAD
=======
resource "aws_subnet" "demo"{
    cidr_block = "10.100.1.0/24"
    vpc_id = aws_vpc.demo.id
    availability_zone = "ap-south-2a"

    tags = {
        name = "HYD SUBNET"
    }
>>>>>>> 31b07a8783c7c21347022e587532b939fc4e236d
}

