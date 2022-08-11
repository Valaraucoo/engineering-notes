terraform {
  required_version = "~> 1.2.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.25"
    }
  }
}

provider "aws" {
	region = "eu-west-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "first-vpc"
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = local.common_tags
}