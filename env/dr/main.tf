resource "aws_db_instance" "dr_restore" {
  identifier          = "dr-mysql"
  instance_class      = var.db_instance_class
  snapshot_identifier = var.snapshot_identifier

  db_subnet_group_name   = aws_db_subnet_group.dr.name
  vpc_security_group_ids = [aws_security_group.dr_rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "dr-mysql"
    Environment = "dr"
  }
}