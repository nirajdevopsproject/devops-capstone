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
  update_default_version = true
  user_data = base64encode(<<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -xe

sudo yum update -y
sudo yum install -y git python3 python3-pip
sudo amazon-linux-extras install nginx1
sudo systemctl enable nginx
sudo systemctl start nginx


cd /opt
git clone https://github.com/nirajdevopsproject/devops-capstone.git ansible

# Export DB variables globally
echo "DB_HOST=${var.db_host}" >> /etc/environment
echo "DB_PORT=${var.db_port}" >> /etc/environment
echo "DB_USER=${var.db_user}" >> /etc/environment
echo "DB_PASS=${var.db_pass}" >> /etc/environment
echo "DB_NAME=${var.db_name}" >> /etc/environment

echo "DB_HOST=${var.db_host}" >> /opt/ansible/app/.env
echo "DB_PORT=${var.db_port}" >> /opt/ansible/app/.env
echo "DB_USER=${var.db_user}" >> /opt/ansible/app/.env
echo "DB_PASS=${var.db_pass}" >> /opt/ansible/app/.env
echo "DB_NAME=${var.db_name}" >> /opt/ansible/app/.env

source /etc/environment

pip3 install -r /opt/ansible/app/requirements.txt
pip3 install ansible

ansible-playbook /opt/ansible/ansible/nginx.yaml -i localhost, -c local

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