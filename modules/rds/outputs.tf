output "rds_address" {
  value = aws_db_instance.this.address
}

output "rds_port" {
  value = aws_db_instance.this.port
}
output "rds_identifier" {
  value = aws_db_instance.this.identifier
}
output "db_instance_id" {
  value = aws_db_instance.this.id
}
