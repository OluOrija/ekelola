resource "aws_secretsmanager_secret" "github_pat" {
  name       = var.github_pat_secret_name
  kms_key_id = aws_kms_key.content.arn
  tags       = local.tags
}
# NOTE: set the secret value out-of-band (console or CI). Lambdas only read it.
