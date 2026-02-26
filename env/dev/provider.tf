provider "aws" {
  region = var.region
}
provider "aws" {
  alias  = "dr"
  region = "ap-southeast-1"
}