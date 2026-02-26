output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

# output "jenkins_sg_id" {
#   value = aws_security_group.jenkins_sg.id
# }