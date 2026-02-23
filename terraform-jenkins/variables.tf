variable "region" {}
variable "env" {}
variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "vpc_id" {}
variable "public_subnet_id" {}
variable "allowed_ip" {
  description = "Your IP for SSH access"
}