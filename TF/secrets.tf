resource "aws_secretsmanager_secret" "dev_secret" {
  name        = "dev_secret"
  description = "This is an dev secret"
}

resource "aws_secretsmanager_secret_version" "dev_secret_version" {
  secret_id     = aws_secretsmanager_secret.dev_secret.id
  secret_string = <<EOF
    {
    "username": "username",
    "password": "password"
    }
    EOF
    # consider using file() function to read from a file
}
