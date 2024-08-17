terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "personal-santi"
}

resource "aws_iam_user" "pm" {
  name = "pm"
  tags = {
    "env" = "dev-certification"
  }
}

resource "aws_iam_user" "dev1" {
  name = "dev1"
  tags = {
    "env" = "dev-certification"
  }
}

resource "aws_iam_user" "dev2" {
  name = "devjunior"
  tags = {
    "env" = "dev-certification"
  }
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group" "managers" {
  name = "managers"
}

# Users Memberships
resource "aws_iam_user_group_membership" "pm_manager" {
  user = aws_iam_user.pm.name

  groups = [
    aws_iam_group.managers.name
  ]
}

resource "aws_iam_user_group_membership" "dev_senior" {
  user = aws_iam_user.dev1.name

  groups = [
    aws_iam_group.managers.name,
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "dev_junior" {
  user = aws_iam_user.dev2.name

  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_role" "ec2_s3_full_access" {
  name = "ec2_s3_full_access"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    env = "dev-certification"
  }
}

resource "aws_iam_group_policy_attachment" "managers_admin" {
  group      = aws_iam_group.managers.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "developer_read_s3" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "developer_read_dynamo" {
  user       = aws_iam_user.dev1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2_s3_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}