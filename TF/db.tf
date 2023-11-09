resource "aws_db_instance" "dev_rds" {
allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "13.3"
  instance_class       = "db.t3.micro"
  db_name              = "devdb"
  username             = "foo"
  password             = "bar"
  parameter_group_name = "default.postgres13"

  # retain backups for 7 days
  backup_retention_period = 7

  storage_encrypted = true
  kms_key_id        = aws_kms_key.devkey.arn
}
