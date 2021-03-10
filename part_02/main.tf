terraform {
    required_providers {
        aws = {   
            source = "hashicorp/aws"
        }
        tls = {   
            source = "hashicorp/tls"
        }
    }
}

provider "tls" {}

provider "aws" {
    region = "eu-west-1"
    profile = "default"
}


resource "tls_private_key" "devops_jrmanes" {
  algorithm   = "RSA"
  ecdsa_curve = 4096
}

resource "aws_key_pair" "devops_jrmanes" {
  key_name   = "jrmanes"
  public_key = tls_private_key.devops_jrmanes.public_key_openssh
}

resource "aws_instance" "jrmanes_ec2" {
    ami = "ami-0aef57767f5404a3c"
    instance_type = "t2.micro"
    key_name = aws_key_pair.devops_jrmanes.key_name
    
    provisioner "remote-exec" {
        inline = [
                "uname -a",
                "ls -ltra /"
        ]
        connection {
            host        = aws_instance.jrmanes_ec2.public_ip
            type        = "ssh"
            user        = "ubuntu"
            private_key = tls_private_key.devops_jrmanes.private_key_pem
            timeout     = "1m"
        }
    }
    tags = {
      Name = "jrmanes_ec2"
    }
}