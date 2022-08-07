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

# Datasource
data "aws_ami" "example" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}

data "aws_availability_zones" "zones" {
	filter {
		name   = "opt-in-status"
		values = ["opt-in-not-required"]
	}
}

data "aws_ec2_instance_type_offerings" "offerings" {
  for_each = toset(data.aws_availability_zones.zones.names)
  location_type = "availability-zone-id"

  filter {
    name   = "instance-type"
    values = ["t2.micro", "t3.micro"]
  }

  filter {
    name   = "location"
    values = [each.key]
  }

}

# Outputs
output "instance_type" {
  value = keys({
    for az, details in data.aws_ec2_instance_type_offerings.offerings:
    az => details.instance_types if length(details.instance_types) > 0
  })
}
