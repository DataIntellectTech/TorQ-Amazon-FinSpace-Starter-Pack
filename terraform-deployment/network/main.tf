variable "region" {
  description = "AWS region"
  type        = string
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "finspace-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "finspace-vpc"
  }
}

data "aws_availability_zones" "finspace-azs" {}

resource "aws_route_table" "finspace-route-table" {
  vpc_id = aws_vpc.finspace-vpc.id
}

resource "aws_subnet" "finspace-subnets" {
  count             = length(data.aws_availability_zones.finspace-azs.names)
  vpc_id            = aws_vpc.finspace-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.finspace-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.finspace-azs.names[count.index]
  
  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "finspace-igw" {
  vpc_id = aws_vpc.finspace-vpc.id
}

resource "aws_route" "finspace-route" {
  route_table_id         = aws_route_table.finspace-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.finspace-igw.id
}

resource "aws_security_group" "finspace-security-group" {
  name   = "finspace-security-group"
  vpc_id = aws_vpc.finspace-vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc-id" {
  value = aws_vpc.finspace-vpc.id
}

output "subnet-ids" {
  value = aws_subnet.finspace-subnets[*].id
}

output "security-group-id" {
  value = aws_security_group.finspace-security-group.id
}
  
