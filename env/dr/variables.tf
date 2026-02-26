variable "snapshot_identifier" {
  description = "Snapshot ID copied to DR region"
  type        = string
}

variable "db_instance_class" {
  default = "db.t3.micro"
}