resource "aws_lambda_function" "trigger" {
  function_name = "${local.name_prefix}-trigger-deploy"
  role          = aws_iam_role.trigger_role.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 60
  memory_size   = 256

  filename         = "${path.module}/lambda_src/trigger_deploy.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_src/trigger_deploy.zip")

  environment {
    variables = {
      GITHUB_OWNER   = var.github_owner
      GITHUB_REPO    = var.github_repo
      WORKFLOW_NAME  = var.workflow_name
      GITHUB_PAT_SEC = var.github_pat_secret_name
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
}
