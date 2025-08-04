resource "aws_s3_bucket" "b2c-transactional-records" {
  bucket = "b2c-transactional-records"
  force_destroy = true

  tags = {
    Name        = "transaction-records"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "b2c_tfstate_file" { # bucket for the tfstate credentials
  bucket = "b2c-tranx-tfstate"
  force_destroy = true 

  tags = {
    Name        = "tfstate-credential"
    Environment = "prod"
  }
}

