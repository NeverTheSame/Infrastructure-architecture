resource "aws_s3_bucket" "dev-bucket" {
  bucket = "dev-bucket"
  acl    = "private"
    tags = {
        Name        = "dev bucket"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dev-encryption" {
  bucket = aws_s3_bucket.dev-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.devkey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "devkey" {
  description = "This key is used to encrypt bucket objects"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "key-consolepolicy-3",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

# for monitoring: 
resource "aws_s3_bucket" "dev-cloudtrail-bucket" {
  bucket = "dev-cloudtrail-bucket"
    tags = {
        Name        = "dev cloudtrail bucket"
    }
}
