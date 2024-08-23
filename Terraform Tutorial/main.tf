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

variable "ec2" {
  type = map(object({
    ami = string
    subnet_id = string
    instance_type = string
    // Security group
    sgs = map(object({
      port = number
    }))
    tags = map(string)
  }))
  default = {
    "Conor's Test Instance" = {
      ami = "ami-0a2202cf4c36161a1"
      instance_type = "t2.micro"
      subnet_id = "subnet-00efc6bfec044e825"
      // Security group
      sgs = {
        administraction = {
          port = 3389
        },
        web = {
          port = 80
        }
      }
      tags = {
        Name = "Conor's Test Instance"
        OS = "Windows"
      }
    },
    "jmeter" = {
      ami           = "ami-0a2202cf4c36161a1"
      subnet_id     = "subnet-00efc6bfec044e825"
      instance_type = "t3.micro"

      sgs = {
        administration = {
          port = 22
        },
        web = {
          port = 80
        }
      }
      tags = {
        Name = "Jmeter"
        OS   = "Linux"
      }
    }
  }
}

resource "aws_security_group" "instance_sg"{
  for_each = var.ec2

  name = "${each.key}-sg"
  description = "Security Group for ${each.key}"

  dynamic "ingress"{
    for_each = each.value.sgs
    content{
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/16"]
      description = "Allow inbound traffic on port ${ingress.value.port}"
    }
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = each.value.tags
}

resource "aws_instance" "this" {
  for_each = var.ec2
  ami = each.value["ami"]
  subnet_id = each.value["subnet_id"]
  instance_type = each.value["instance_type"]
  tags = each.value["tags"]
  iam_instance_profile = aws_iam_instance.ec2_profile.name
  key_name = aws_key_pair.developer.key_name
  vpc_security_group_ids = [
    each.value.tags.OS == "Windows" ? aws_security_group.instance_sg["burpsuite"].id : aws_security_group.instance_sg["jmeter"].id
  ]
}



# resource "aws_instance" "example_server" {
#   ami = "ami-0a2202cf4c36161a1"
#   instance_type = "t2.micro"

#   tags ={
#     Name = "Conor's Test Instance"
#   }
# }