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

# resource "aws_eip" "nat" {
#   count = 1
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.base_name
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24", ]

  map_public_ip_on_launch = true

  # enable_nat_gateway     = true
  # single_nat_gateway     = true
  # one_nat_gateway_per_az = false
  # reuse_nat_ips          = true             # <= Skip creation of EIPs for the NAT Gateways
  # external_nat_ip_ids    = aws_eip.nat.*.id # <= IPs specified here as input to the module

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# resource "aws_s3_bucket" "init" {
#   bucket = local.base_name
# }

module "client" {
  source = "./modules/client"

  name = local.base_name

  region           = var.region
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnets[0]
}


# resource "aws_s3_object" "debezium" {
#   bucket = aws_s3_bucket.init.id
#   key    = "debezium-init-script"
#   content = templatefile("modules/debezium/init.sh.tpl", {
#     CLIENT_IP = module.client.ec2_client_instance_private_ip
#   })
# }



# module "debezium" {
#   source = "./modules/debezium"

#   name = local.base_name

#   region = var.region
#   vpc_id = module.vpc.vpc_id
#   # private_subnet_id = module.vpc.private_subnets[0]
#   private_subnet_id = module.vpc.public_subnets[1]

#   client_private_ip = module.client.ec2_client_instance_private_ip #Privte client's IP
#   client_sg_id      = module.client.ec2_client_sg_id
# }

