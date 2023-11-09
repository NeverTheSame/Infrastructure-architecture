resource "aws_db_instance_automated_backups_replication" "dev-replication" {
  source_db_instance_arn = aws_db_instance.dev_rds.arn
  # if encrypted with KMS:
  kms_key_id             = aws_kms_key.devkey.arn
  retention_period = 7
}
