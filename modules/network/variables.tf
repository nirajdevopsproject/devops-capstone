variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "private_app_subnets" {
  description = "Private App subnet CIDR blocks"
  type        = list(string)
}

variable "private_db_subnets" {
  description = "Private DB subnet CIDR blocks"
  type        = list(string)
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "env" {
  description = "Environment name"
  type        = string
}