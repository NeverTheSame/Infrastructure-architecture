terraform {
  backend "s3" {
    bucket = "tf-state-bucket"
    key    = aws_kms_key.devkey.arn
    region = "us-west-2"
  }
}
