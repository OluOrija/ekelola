resource "aws_cloudwatch_log_group" "validate" {
  name              = "/aws/lambda/${local.name_prefix}-validate-mdx"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.content.arn
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "trigger" {
  name              = "/aws/lambda/${local.name_prefix}-trigger-deploy"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.content.arn
  tags              = local.tags
}
