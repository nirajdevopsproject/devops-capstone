variable "env" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}
variable "db_host" {}
variable "db_name" {}
variable "db_user" {}
variable "db_pass" {}
variable "db_port" {}