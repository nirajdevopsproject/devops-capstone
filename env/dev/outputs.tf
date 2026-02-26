output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "public_subnets" {
  value = module.network.public_subnet_ids
}

output "private_app_subnets" {
  value = module.network.private_app_subnet_ids
}

output "private_db_subnets" {
  value = module.network.private_db_subnet_ids
}
output "rds_endpoint" {
  value = module.rds.rds_endpoint
}
output "alb_arn_suffix" {
  value = module.alb.alb_arn_suffix
}
output "jenkins_url" {
  value = module.jenkins.jenkins_url
}