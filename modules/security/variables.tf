variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SSH/Jenkins access"
  type        = string
}