terraform {
  backend "s3" {
    bucket = "tf-backend-muna"
    region = "us-east-1"
    key    = "hands0n-1-sf"

  }
}