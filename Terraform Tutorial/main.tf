terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
  // AWS CLI Profile name
  profile = "default"
}

resource "aws_instance" "example_server" {
  ami = "ami-0a2202cf4c36161a1"
  instance_type = "t2.micro"

  tags ={
    Name = "Conor's Test Instance"
  }
}