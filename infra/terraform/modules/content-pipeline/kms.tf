resource "aws_kms_key" "content" {
  description         = "KMS for ${local.name_prefix} content buckets & logs"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_kms_alias" "content" {
  name          = var.kms_alias
  target_key_id = aws_kms_key.content.id
}
