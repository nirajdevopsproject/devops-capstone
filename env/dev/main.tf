module "network" {
  source = "../../modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_app_subnets = var.private_app_subnets
  private_db_subnets  = var.private_db_subnets
  azs                 = var.azs
  env                 = var.env
}
module "security" {
  source = "../../modules/security"

  vpc_id = module.network.vpc_id
  env    = var.env
  my_ip  = var.my_ip
}
module "alb" {
  source = "../../modules/alb"

  env               = var.env
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}
module "compute" {
  source = "../../modules/compute"

  env                     = var.env
  private_app_subnet_ids  = module.network.private_app_subnet_ids
  app_sg_id               = module.security.app_sg_id
  target_group_arn        = module.alb.target_group_arn
  instance_type           = var.instance_type
  key_name                = var.key_name
  db_port = module.rds.rds_port
  db_host = module.rds.rds_address
  db_name = var.db_name
  db_user = var.db_username
  db_pass = var.db_password
}
module "rds" {
  source = "../../modules/rds"

  env                  = var.env
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = module.network.db_subnet_group_name
  rds_sg_id            = module.security.rds_sg_id
  instance_class       = var.db_instance_class
}
resource "aws_kms_key" "dr_rds" {
  provider = aws.dr

  description = "DR RDS snapshot encryption key"
}

resource "aws_kms_alias" "dr_rds_alias" {
  provider = aws.dr

  name          = "alias/dr-rds-key"
  target_key_id = aws_kms_key.dr_rds.key_id
}
resource "aws_db_snapshot" "manual" {
  db_instance_identifier = module.rds.rds_identifier
  db_snapshot_identifier = "${var.env}-manual-snap"
}
resource "aws_db_snapshot_copy" "dr_copy" {
  provider = aws.dr
  depends_on = [aws_db_snapshot.manual]
  source_db_snapshot_identifier = aws_db_snapshot.manual.db_snapshot_arn
  target_db_snapshot_identifier = "${var.env}-dr-snap"

  kms_key_id = aws_kms_key.dr_rds.arn
}
module "monitoring" {
  source = "../../modules/monitoring"

  env             = var.env
  alert_email     = var.alert_email
  asg_name        = module.compute.asg_name
  rds_identifier  = module.rds.rds_identifier
  alb_arn_suffix  = module.alb.alb_dns_name
}
module "jenkins" {
  source = "../../modules/jenkins"

  env              = var.env
  public_subnet_id = module.network.public_subnet_ids[0]
  jenkins_sg_id    = module.security.jenkins_sg_id
  key_name         = var.key_name
  instance_type    = "t3.micro"
}
