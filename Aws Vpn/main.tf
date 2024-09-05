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
}

# Define a VPC
resource "aws_vpc" "conor-VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "conor-vpc"
  }
}

# Define an Internet Gateway
resource "aws_internet_gateway" "conor-internet-gateway" {
  vpc_id = aws_vpc.conor-VPC.id
  tags = {
    Name = "conor-igw"
  }
}

# Define a Subnet
resource "aws_subnet" "conor-subnet" {
  vpc_id            = aws_vpc.conor-VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"  # Replace with your preferred availability zone
  tags = {
    Name = "conor-subnet"
  }
}

# Define a Route Table
resource "aws_route_table" "conor-route-table" {
  vpc_id = aws_vpc.conor-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.conor-internet-gateway.id
  }
  tags = {
    Name = "conor-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "conor-route-table-association" {
  subnet_id      = aws_subnet.conor-subnet.id
  route_table_id = aws_route_table.conor-route-table.id
}

# Define a Security Group
resource "aws_security_group" "conor-security-group" {
  vpc_id = aws_vpc.conor-VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.40.86/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.40.86/32"]
  }
  tags = {
    Name = "conor-security-group"
    
  }
}

# Define an EC2 Instance
resource "aws_instance" "conor-instance" {
  ami           = "ami-04e49d62cf88738f1"  # Replace with the desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.conor-subnet.id
  security_groups = [aws_security_group.conor-security-group.id]
  key_name = "conor_vpn_test_pair"

  tags = {
    Name = "conor-VPN-test-instance"
    Owner = "Shauna-Test-Tag"
  }
}

# Define a Customer Gateway
resource "aws_customer_gateway" "conor-customer-gateway" {
  bgp_asn    = 65000
  ip_address = "208.67.222.222"  
  type       = "ipsec.1"

  tags = {
    Name = "conor-customer-gateway"
    Owner = "Shauna-New-Test-Tag"
  }
}

# Define a VPN Gateway
resource "aws_vpn_gateway" "conor-vpn-gateway" {
  vpc_id = aws_vpc.conor-VPC.id

  tags = {
    Name = "conor-vpn-gateway"
  }
}

# Attach VPN Gateway to VPC
resource "aws_vpn_gateway_attachment" "conor-vpn-gateway-attachment" {
  vpc_id        = aws_vpc.conor-VPC.id
  vpn_gateway_id = aws_vpn_gateway.conor-vpn-gateway.id
}

# Define a VPN Connection
resource "aws_vpn_connection" "conor-vpn-connection" {
  customer_gateway_id = aws_customer_gateway.conor-customer-gateway.id
  vpn_gateway_id      = aws_vpn_gateway.conor-vpn-gateway.id
  type                = "ipsec.1"

  static_routes_only = true  # Set to false if using dynamic routing (BGP) test

  tags = {
    Name = "conor-vpn-connection"
  }
}

# Define a VPN Connection Route 
resource "aws_vpn_connection_route" "conor-vpn-route" {
  vpn_connection_id      = aws_vpn_connection.conor-vpn-connection.id
  destination_cidr_block = "10.0.40.0/24"  # Replace with your on-premises network's CIDR block
}

# Update the Route Table to Route On-Premises Traffic through VPN asdf
resource "aws_route" "vpn_route" {
  route_table_id         = aws_route_table.conor-route-table.id
  destination_cidr_block = "255.255.255.0/24"  # Replace with your on-premises network's CIDR block
  gateway_id             = aws_vpn_gateway.conor-vpn-gateway.id
}

# Output the Instance Public IP
output "instance_public_ip" {
  value = aws_instance.conor-instance.public_ip
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.conor-VPC.id
}

# Output the Subnet ID
output "subnet_id" {
  value = aws_subnet.conor-subnet.id
}
