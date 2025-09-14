resource "aws_lambda_function" "validate" {
  function_name = "${local.name_prefix}-validate-mdx"
  role          = aws_iam_role.validate_role.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 60
  memory_size   = 256

  filename         = "${path.module}/lambda_src/validate_mdx.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_src/validate_mdx.zip")

  environment {
    variables = {
      LIVE_BUCKET        = aws_s3_bucket.live.bucket
      REJECTED_BUCKET    = aws_s3_bucket.rejected.bucket
      MAX_MDX_SIZE_BYTES = tostring(var.max_mdx_size_bytes)
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
}
