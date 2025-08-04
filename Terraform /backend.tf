terraform {
  backend "s3" {
    bucket = "b2c-tranx-tfstate"
    key    = "key/terraform.tfstate"
    region = "eu-north-1"
  }
}