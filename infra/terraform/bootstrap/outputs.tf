output "state_bucket" { value = aws_s3_bucket.tfstate.bucket }
output "lock_table" { value = aws_dynamodb_table.lock.name }
output "github_oidc_provider" { value = aws_iam_openid_connect_provider.github.arn }
output "terraform_role_arn" { value = aws_iam_role.tf_role.arn }
