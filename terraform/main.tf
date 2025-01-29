terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46"
    }
  }
}


provider "aws" {
  region = var.region
}

locals {
  base_name = "${var.prefix}${var.separator}${var.name}"
}

resource "aws_eip" "nat" {
  count = 1
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.base_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  reuse_nat_ips          = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids    = aws_eip.nat.*.id # <= IPs specified here as input to the module

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "client" {
  source = "./modules/client"

  name = local.base_name

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnets[0]
}


