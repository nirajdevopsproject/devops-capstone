# getting ami for lauch template
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
#lauch template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.env}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data = base64encode(<<-EOF
  #!/bin/bash
  exec > /var/log/user-data.log 2>&1
  set -x

  #  Export DB variables
  export DB_HOST="${var.db_host}"
  export DB_USER="${var.db_user}"
  export DB_PASS="${var.db_pass}"
  export DB_NAME="${var.db_name}"

  # Install dependencies
  yum update -y
  yum install -y git
  amazon-linux-extras enable ansible2
  yum install -y ansible

  # Run ansible-pull
  ansible-pull -U https://github.com/nirajdevopsproject/devops-capstone.git \
  -d /opt/ansible \
  -i localhost, \
  -c local \
  ansible/nginx.yaml

EOF
)
  vpc_security_group_ids = [var.app_sg_id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-app-instance"
    }
  }
}
#auto scaling group
resource "aws_autoscaling_group" "this" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.private_app_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "${var.env}-asg-instance"
    propagate_at_launch = true
  }
}