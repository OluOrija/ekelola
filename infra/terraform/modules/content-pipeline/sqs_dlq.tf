resource "aws_sqs_queue" "dlq" {
  name                      = "${local.name_prefix}-content-dlq"
  message_retention_seconds = 1209600
  kms_master_key_id         = aws_kms_key.content.arn
  tags                      = local.tags
}
