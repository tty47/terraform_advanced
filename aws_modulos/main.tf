terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.region_aws
  profile = "default"
}

module "keys" {
  source             = "./keys"
  longitud_clave_rsa = 4096
  id_clave           = var.id_clave
}

module "network" {
  source = "./vpc"

  vpc_name   = "jrmanes_vpc"
  cidr_block = "10.0.0.0/16"
  subnets = [
    {
      "subnet_name" : "ivan-publica",
      "subnet_cidr" : "10.0.1.0/24",
      "subnet_az_name" : null,
      "subnet_az_id" : null,
      "subnet_public" : true
    },
    {
      "subnet_name" : "ivan-privada",
      "subnet_cidr" : "10.0.2.0/24",
      "subnet_az_name" : null,
      "subnet_az_id" : null,
      "subnet_public" : false
    }
  ]
}