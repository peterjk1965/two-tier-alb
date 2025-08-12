terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }

  backend "s3" {
    bucket         = "pjk-terraform-state-bucket2"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region                   = "us-east-2"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}



# 1. Create a custom VPC
resource "aws_vpc" "pjk-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "pjk-vpc"
  }
}

# 2. Create and attach the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pjk-vpc.id

  tags = {
    Name = "pjk-vpc-igw"
  }
}

# 3. Create public and private subnets
resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = aws_vpc.pjk-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az-1
  map_public_ip_on_launch = true

  tags = {
    Name = "pjk-public-subnet-1a"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id                  = aws_vpc.pjk-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.az-2
  map_public_ip_on_launch = true

  tags = {
    Name = "pjk-public-subnet-1b"
  }
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id            = aws_vpc.pjk-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az-1

  tags = {
    Name = "pjk-private-subnet-1a"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id            = aws_vpc.pjk-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.az-2

  tags = {
    Name = "pjk-private-subnet-1b"
  }
}


# 4. Create a NAT gateway
resource "aws_eip" "elastic-ip" {
  vpc = true

  tags = {
    Name = "pjk-nat-eip"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.public-subnet-a.id

  tags = {
    Name = "pjk-NAT-Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# 5. Create custom route tables
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.pjk-vpc.id

  route {
    cidr_block = var.all-ipv4
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pjk-public-route-table"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.pjk-vpc.id

  route {
    cidr_block = var.all-ipv4
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "pjk-private-route-table"
  }
}

# 6. Subnet association with route table
resource "aws_route_table_association" "public_rt_assoc_a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public_rt_assoc_b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private_rt_assoc_a" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private_rt_assoc_b" {
  subnet_id      = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.private-rt.id
}


