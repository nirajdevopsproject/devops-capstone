terraform {
  backend "s3" {
    bucket         = "81f468449b4742523"
    key            = "devops-capstone/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}