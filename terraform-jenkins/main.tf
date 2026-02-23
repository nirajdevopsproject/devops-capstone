
# Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.env}-jenkins-sg"
  description = "Allow SSH and Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-jenkins-sg"
  }
}
# IAM Role
resource "aws_iam_role" "jenkins_role" {
  name = "${var.env}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_admin" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.env}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

# EC2 Instance
resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-17-amazon-corretto wget git

              wget -O /etc/yum.repos.d/jenkins.repo \
              https://pkg.jenkins.io/redhat-stable/jenkins.repo

              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

              yum install -y jenkins
              systemctl enable jenkins
              systemctl start jenkins

              # Install Terraform
              yum install -y unzip
              wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
              unzip terraform_1.6.6_linux_amd64.zip
              mv terraform /usr/local/bin/

              # Install Ansible
              amazon-linux-extras enable ansible2
              yum install -y ansible

              echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
              EOF

  tags = {
    Name = "${var.env}-jenkins"
  }
}
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "${var.env}-jenkins-eip"
  }
}