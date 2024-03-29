output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "azs" {
  value = data.aws_availability_zones.available.names
}

output "ami" {
  value = data.aws_ami.ami.image_id
}