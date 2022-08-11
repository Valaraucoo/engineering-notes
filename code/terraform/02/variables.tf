variable "cidr" {
  description = "CIRD for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private VPC Subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public VPC Subnets"
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}