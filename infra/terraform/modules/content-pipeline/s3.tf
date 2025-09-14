resource "aws_s3_bucket" "incoming" {
  bucket = "${local.name_prefix}-content-incoming"
  tags   = local.tags
}

resource "aws_s3_bucket" "live" {
  bucket = "${local.name_prefix}-content-live"
  tags   = local.tags
}

resource "aws_s3_bucket" "rejected" {
  bucket = "${local.name_prefix}-content-rejected"
  tags   = local.tags
}

# Versioning
resource "aws_s3_bucket_versioning" "v_incoming" {
  bucket = aws_s3_bucket.incoming.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_versioning" "v_live" {
  bucket = aws_s3_bucket.live.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_versioning" "v_rejected" {
  bucket = aws_s3_bucket.rejected.id
  versioning_configuration { status = "Enabled" }
}

# SSE-KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_incoming" {
  bucket = aws_s3_bucket.incoming.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.content.arn
    }
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_live" {
  bucket = aws_s3_bucket.live.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.content.arn
    }
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_rejected" {
  bucket = aws_s3_bucket.rejected.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.content.arn
    }
  }
}

# Block public
resource "aws_s3_bucket_public_access_block" "pab_incoming" {
  bucket = aws_s3_bucket.incoming.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_public_access_block" "pab_live" {
  bucket = aws_s3_bucket.live.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_public_access_block" "pab_rejected" {
  bucket = aws_s3_bucket.rejected.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Lifecycle: expire noncurrent after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "lc_incoming" {
  bucket = aws_s3_bucket.incoming.id
  rule {
    id     = "expire-noncurrent"
    status = "Enabled"
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "lc_live" {
  bucket = aws_s3_bucket.live.id
  rule {
    id     = "expire-noncurrent"
    status = "Enabled"
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "lc_rejected" {
  bucket = aws_s3_bucket.rejected.id
  rule {
    id     = "expire-noncurrent"
    status = "Enabled"
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
