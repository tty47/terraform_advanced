// VPC MOFULE
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  ingress = {
    "22" : {
      "to_port" : 22
      "protocol" : "tcp"
      "cidr_blocks" : ["0.0.0.0/0"]
    },
    "8080" : {
      "to_port" : 8080
      "protocol" : "tcp"
      "cidr_blocks" : ["0.0.0.0/0"]
    },
    "3306" : {
      "to_port" : 3306
      "protocol" : "tcp"
      "cidr_blocks" : ["10.0.0.0/8"]
    }
  }

}

// VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

// Subnets 
resource "aws_subnet" "vpc_subnet" {
  count                   = length(var.subnets)
  availability_zone     = var.subnets[count.index].subnet_az_name
  availability_zone_id    = var.subnets[count.index].subnet_az_id
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnets[count.index].subnet_cidr

}

// GATEWAY
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}_gw"
  }
}

// ROUTER
// one way to do that will be, all in one block
#resource "aws_route_table" "route" {
#  vpc_id = aws_vpc.vpc.id
#  route {
#    cidr_block = "10.0.1.0/24"
#    gateway_id = aws_internet_gateway.main.id
#  }
#  route {
#    ipv6_cidr_block        = "::/0"
#    egress_only_gateway_id = aws_egress_only_internet_gateway.foo.id
#  }
#  tags = {
#    Name = "main"
#  }
#}
resource "aws_route_table" "router" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "router"
  }
}

// INTERNET ROUTEeck out our job postings where you can view the preferred location(s)
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.router.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

// SUBNET ASSOCIATION
resource "aws_route_table_association" "subnets_connection" {
  count          = length(aws_subnet.vpc_subnet) 
  subnet_id      = aws_subnet.vpc_subnet[count.index].id
  route_table_id = aws_route_table.router.id
}

// SECURITY GROUP
resource "aws_security_group" "sg_jrmanes" {
  name        = "${var.vpc_name}_sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  dynamic "ingress" {
    iterator = current_ingress
    for_each = local.ingress
    
    content {
      from_port = current_ingress.key
      to_port = current_ingress.value["to_port"]
      protocol = current_ingress.value["protocol"]
      cidr_blocks = current_ingress.value["cidr_blocks"]
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}