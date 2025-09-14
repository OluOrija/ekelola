# Allow S3 to invoke Lambdas
resource "aws_lambda_permission" "allow_s3_incoming" {
  statement_id  = "AllowS3InvokeValidate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validate.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.incoming.arn
}

resource "aws_lambda_permission" "allow_s3_live" {
  statement_id  = "AllowS3InvokeTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.live.arn
}

# S3 → Lambda notifications (suffix .mdx)
resource "aws_s3_bucket_notification" "incoming_notify" {
  bucket = aws_s3_bucket.incoming.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.validate.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mdx"
  }

  depends_on = [aws_lambda_permission.allow_s3_incoming]
}

resource "aws_s3_bucket_notification" "live_notify" {
  bucket = aws_s3_bucket.live.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".mdx"
  }

  depends_on = [aws_lambda_permission.allow_s3_live]
}
