variable "region" {}
variable "env" {}
variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_app_subnets" { type = list(string) }
variable "private_db_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "my_ip" {}
variable "instance_type" {}
variable "key_name" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
variable "db_instance_class" {}
variable "alert_email" {}