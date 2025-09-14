output "incoming_bucket"            { value = aws_s3_bucket.incoming.bucket }
output "live_bucket"                { value = aws_s3_bucket.live.bucket }
output "rejected_bucket"            { value = aws_s3_bucket.rejected.bucket }
output "validate_lambda_arn"        { value = aws_lambda_function.validate.arn }
output "trigger_lambda_arn"         { value = aws_lambda_function.trigger.arn }
output "github_pat_secret_arn"      { value = aws_secretsmanager_secret.github_pat.arn }
