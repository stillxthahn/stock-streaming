terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  prefix    = var.environment_name
  separator = "-"
  name      = var.name

  vpc_cidr_block = var.vpc_cidr_block
}

module "client" {
  source = "./modules/client"

  prefix    = var.environment_name
  separator = "-"
  name      = var.name

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
}


