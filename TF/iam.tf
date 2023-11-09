# Define the IAM user
resource "aws_iam_user" "dev-user" {
  name = "dev-user"
  path = "/system/"
}

resource "aws_iam_policy" "dev-policy" {
  name        = "dev-policy"
  path        = "/system/"
  description = "A dev policy"

  # Define the policy document to work with EKS
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


# Define the IAM role
resource "aws_iam_role" "dev-role" {
  name = "dev-role"
  path = "/system/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "dev-attach" {
  role       = aws_iam_role.dev-role.name
  policy_arn = aws_iam_policy.dev-policy.arn
}

# Create an IAM instance profile that we can attach to the instance
resource "aws_iam_instance_profile" "dev-profile" {
  name = "deve_profile"
  role = aws_iam_role.dev-role.name
}
