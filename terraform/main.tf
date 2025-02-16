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
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

locals {
  base_name                 = "${var.prefix}${var.separator}${var.name}"
  s3_stock_bucket           = "${var.prefix}${var.separator}${var.name}-ibm"
  s3_stock_bucket_processed = "${var.prefix}${var.separator}${var.name}-ibm-processed"
  s3_script_bucket          = "${var.prefix}${var.separator}${var.name}-script"
}

module "s3" {
  source = "./modules/s3"

  name = local.base_name

  s3_stock_bucket           = local.s3_stock_bucket
  s3_stock_bucket_processed = local.s3_stock_bucket_processed
  s3_stock_folder           = var.s3_stock_folder
  s3_script_bucket          = local.s3_script_bucket
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.base_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "ec2" {
  source = "./modules/ec2"

  name = local.base_name

  access_key        = var.access_key
  secret_key        = var.secret_key
  region            = var.region
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnets[0]
  private_subnet_id = module.vpc.private_subnets[0]

  s3_stock_bucket_endpoint = module.s3.s3_stock_bucket_endpoint
  s3_stock_bucket          = local.s3_stock_bucket
  s3_stock_folder          = var.s3_stock_folder

  depends_on = [module.vpc]
}

# module "database" {
#   source = "./modules/database"

#   name = local.base_name

#   region            = var.region
#   vpc_id            = module.vpc.vpc_id
#   private_subnet_id = module.vpc.private_subnets[0]

#   client_sg_id   = module.client.client_sg_id
#   debezium_sg_id = module.debezium.debezium_sg_id

#   depends_on = [module.vpc]
# }

# module "debezium" {
#   source = "./modules/debezium"

#   name = local.base_name

#   region            = var.region
#   vpc_id            = module.vpc.vpc_id
#   private_subnet_id = module.vpc.private_subnets[0]

#   database_sg_id = module.database.database_sg_id
#   database_host  = module.database.database_private_ip

#   depends_on = [module.vpc]
# }

# module "client" {
#   source = "./modules/client"

#   name = local.base_name

#   region           = var.region
#   vpc_id           = module.vpc.vpc_id
#   public_subnet_id = module.vpc.public_subnets[0]

#   database_sg_id = module.database.database_sg_id
#   database_host  = module.database.database_private_ip

#   depends_on = [module.vpc]
# }

# module "spark" {
#   source = "./modules/spark"

#   name = local.base_name

#   access_key = var.access_key
#   secret_key = var.secret_key

#   region            = var.region
#   vpc_id            = module.vpc.vpc_id
#   private_subnet_id = module.vpc.private_subnets[0]

#   debezium_private_ip = module.debezium.debezium_private_ip
#   debezium_sg_id      = module.debezium.debezium_sg_id

#   s3_stock_bucket_endpoint = module.s3.s3_stock_bucket_endpoint
#   s3_stock_bucket          = local.s3_stock_bucket
#   s3_stock_folder          = var.s3_stock_folder


#   depends_on = [module.vpc]
# }

module "glue" {
  source = "./modules/glue"

  name                      = local.base_name
  s3_stock_bucket           = local.s3_stock_bucket
  s3_stock_bucket_processed = local.s3_stock_bucket_processed
  s3_stock_folder           = var.s3_stock_folder
  s3_script_bucket          = local.s3_script_bucket
}
