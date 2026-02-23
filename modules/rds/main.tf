resource "aws_db_instance" "this" {
  identifier = "${var.env}-mysql"

  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.instance_class
  allocated_storage    = 20
  storage_type         = "gp2"
  storage_encrypted    = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az               = false
  publicly_accessible    = false
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_sg_id]

  backup_retention_period = 0
  skip_final_snapshot     = false
  deletion_protection     = false

  tags = {
    Name = "${var.env}-mysql"
  }
}