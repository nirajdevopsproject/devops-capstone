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
yum update -y

amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "<h1>DevOps Capstone</h1>
<h2>Instance ID: $INSTANCE_ID</h2>" > /usr/share/nginx/html/index.html
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