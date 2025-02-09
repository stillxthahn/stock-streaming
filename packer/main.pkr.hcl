packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "environment_name" {
  type    = string
  default = null
}

variable "name" {
  type    = string
  default = null
}

variable "separator" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

source "amazon-ebs" "client" {
  ami_name      = "${var.environment_name}${var.separator}${var.name}${var.separator}client${var.separator}ami"
  instance_type = "t2.micro"
  region        = var.region
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "client-ami"
  sources = [
    "source.amazon-ebs.client"
  ]

  provisioner "shell" {
    script = "./scripts/client_init.sh"
  }
}