data "aws_caller_identity" "current" {}

resource "aws_kms_key" "content" {
  description         = "KMS for ${local.name_prefix} content buckets & logs"
  enable_key_rotation = true
  tags                = local.tags
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAccountAdmin",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow CW Logs",
      "Effect": "Allow",
      "Principal": { "Service": "logs.eu-west-2.amazonaws.com" },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "content" {
  name          = var.kms_alias
  target_key_id = aws_kms_key.content.id
}
