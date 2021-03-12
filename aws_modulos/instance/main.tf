terraform {
    required_providers {
        aws = {   
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
    profile = "default"
}
uenta el

variable "aws_ami_owners" {
    description = "owners"
    type = string
}

variable "aws_ami_" {
    description = "owners"
    type = string
}

variable "aws_ami_owners" {
    description = "owners"
    type = string
}



// create a key pair
resource "tls_private_key" "devops_jrmanes" {
  algorithm   = "RSA"
  rsa_bits    = "4096"
  
  provisioner "local-exec" {
      command = "echo \"${self.private_key_pem}\" > private_key.pem"
  }
  
  provisioner "local-exec" {
       command = "echo \"${self.public_key_pem}\" > public_key.pem"
  }
}

// set name to public key
resource "aws_key_pair" "devops_jrmanes" {
  key_name   = "jrmanes"
  public_key = tls_private_key.devops_jrmanes.public_key_openssh
}

// create the security_groups
resource "aws_security_group" "rules_devops_jrmanes" {
  name        = "rules_devops_jrmanes"
  description = "rules_devops_jrmanes"

  ingress {    
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {    
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

// use the ubuntu image
data "aws_ami" "ami_ubuntu" {
    most_recent = true
    owners = [ "099720109477" ]
    
    filter {
        name   ="name"
        values = [ "*ubuntu-xenial-16.04-amd64-server-*" ]
    }
    
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

// create an ebs volume
resource "aws_ebs_volume" "ebs_devops_jrmanes" {
  availability_zone = aws_instance.jrmanes_ec2.availability_zone
  size              = 8

  tags = {
    Name = "${aws_instance.jrmanes_ec2.tags.Name}_jrmanes_ebs"
  }
}

// attach this ebs to the instance
resource "aws_volume_attachment" "ebs_att_devops_jrmanes" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_devops_jrmanes.id
  instance_id = aws_instance.jrmanes_ec2.id
}

// generate the ec2
resource "aws_instance" "jrmanes_ec2" {
    ami           = data.aws_ami.ami_ubuntu.id
    instance_type = "t2.micro"
    key_name = aws_key_pair.devops_jrmanes.key_name
       
    security_groups = [
        aws_security_group.rules_devops_jrmanes.name
    ]

    connection {
        type         = "ssh"
        host         = self.public_ip
        user         = "ubuntu"
        private_key  = tls_private_key.devops_jrmanes.private_key_pem
        port         = 22
    }
       
    provisioner "remote-exec" {
        inline = [ "sudo apt-get update", "sudo apt-get install ansible python -y", "which ansible"]
    }
    provisioner "local-exec" {
        command =  "echo \"${self.public_ip} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_ssh_private_key_file=./private_key.pem\" > inventary.ini"
    }
    
    provisioner "local-exec" {
        command =  "/usr/bin/ansible-playbook -i ./inventary.ini playbook.yaml"
    }

    tags = {
      Name = "jrmanes_ec2"
    }
}