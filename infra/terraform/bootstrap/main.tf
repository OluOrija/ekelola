locals { tags = { Project = var.project_name, ManagedBy = "terraform-bootstrap" } }

data "aws_caller_identity" "current" {}

# S3 tfstate bucket
resource "aws_s3_bucket" "tfstate" {
  bucket        = var.state_bucket
  force_destroy = false
  tags          = local.tags
}
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB lock table
resource "aws_dynamodb_table" "lock" {
  name         = var.lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.tags
}

# GitHub OIDC provider (one per account)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# IAM role assumable by GitHub Actions (OIDC)
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:ref:${var.allowed_ref_main}"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:ref:${var.allowed_ref_branch1}"]
    }    
  }
}
resource "aws_iam_role" "tf_role" {
  name               = "${var.project_name}-terraform-gha"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = local.tags
}

# Least-privilege policy for TF managing this infra
data "aws_iam_policy_document" "tf_policy" {
  statement {
    sid       = "S3State"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.tfstate.arn, "${aws_s3_bucket.tfstate.arn}/*"]
  }
  statement {
    sid     = "S3Site"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.site_bucket_name}", "arn:aws:s3:::${var.site_bucket_name}/*",
      "arn:aws:s3:::${var.logs_bucket_name}", "arn:aws:s3:::${var.logs_bucket_name}/*"
    ]
  }
  statement {
    sid       = "Route53"
    actions   = [
      "route53:ListHostedZones",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
      "route53:ListTagsForResource"
    ]
    resources = ["*"]
    # Optionally scope ChangeResourceRecordSets to hosted zone:
    # resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }
  statement {
    sid       = "CloudFront"
    actions   = ["cloudfront:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ACM"
    actions   = ["acm:*"]
    resources = ["*"]
  }
  statement {
    sid       = "DynamoDBLock"
    actions   = ["dynamodb:*"]
    resources = [aws_dynamodb_table.lock.arn]
  }
  statement {
    sid       = "IAMRead"
    actions   = ["iam:GetRole", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies"]
    resources = ["*"]
  }
  statement {
    sid       = "S3ReadConfig"
    actions   = [
      "s3:GetBucketVersioning",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetLifecycleConfiguration"
    ]
    resources = [
      "arn:aws:s3:::${var.site_bucket_name}",
      "arn:aws:s3:::${var.logs_bucket_name}",
      aws_s3_bucket.tfstate.arn
    ]
  }
  statement {
    sid       = "KMSDescribe"
    actions   = ["kms:DescribeKey"]
    resources = ["arn:aws:kms:eu-west-2:${data.aws_caller_identity.current.account_id}:key/*"]
  }
  statement {
    sid       = "SecretsManagerContentPAT"
    actions   = [
      "secretsmanager:CreateSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:TagResource"
    ]
  resources = ["arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:ekelola/github/pat_content_sync-*"]
  }
}
resource "aws_iam_policy" "tf_policy" {
  name   = "${var.project_name}-terraform-gha-policy"
  policy = data.aws_iam_policy_document.tf_policy.json
}
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.tf_role.name
  policy_arn = aws_iam_policy.tf_policy.arn
}
