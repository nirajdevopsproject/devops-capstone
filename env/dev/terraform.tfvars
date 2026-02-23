region = "ap-south-1"
env    = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
private_db_subnets  = ["10.0.5.0/24", "10.0.6.0/24"]

azs = ["ap-south-1a", "ap-south-1b"]
my_ip = "0.0.0.0/0"
instance_type = "t3.micro"
key_name      = "jenkins"
db_name           = "devopsdb"
db_username       = "admin"
db_password       = "StrongPassword123!"
db_instance_class = "db.t3.micro"
alert_email = "nirajvishwa894@gmail.com"