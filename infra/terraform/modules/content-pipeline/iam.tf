data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "validate_role" {
  name               = "${local.name_prefix}-validate-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
  tags               = local.tags
}

resource "aws_iam_role" "trigger_role" {
  name               = "${local.name_prefix}-trigger-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
  tags               = local.tags
}

# Policies
data "aws_iam_policy_document" "validate_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.incoming.arn}/*"]
  }
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.live.arn}/*", "${aws_s3_bucket.rejected.arn}/*"]
  }
  statement {
    actions   = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
    resources = ["*"]
  }
  statement {
    actions   = ["kms:Decrypt","kms:Encrypt","kms:GenerateDataKey"]
    resources = [aws_kms_key.content.arn]
  }
}

resource "aws_iam_policy" "validate_policy" {
  name   = "${local.name_prefix}-validate-policy"
  policy = data.aws_iam_policy_document.validate_policy.json
}
resource "aws_iam_role_policy_attachment" "validate_attach" {
  role       = aws_iam_role.validate_role.name
  policy_arn = aws_iam_policy.validate_policy.arn
}

data "aws_iam_policy_document" "trigger_policy" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.github_pat.arn]
  }
  statement {
    actions   = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
    resources = ["*"]
  }
  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.content.arn]
  }
  # Optional: read live content for future enrichment
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.live.arn, "${aws_s3_bucket.live.arn}/*"]
  }
  # Allow Lambda to send to DLQ if using DLQ config
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.dlq.arn]
  }
}

resource "aws_iam_policy" "trigger_policy" {
  name   = "${local.name_prefix}-trigger-policy"
  policy = data.aws_iam_policy_document.trigger_policy.json
}
resource "aws_iam_role_policy_attachment" "trigger_attach" {
  role       = aws_iam_role.trigger_role.name
  policy_arn = aws_iam_policy.trigger_policy.arn
}

# AWS managed basic execution for Lambda
resource "aws_iam_role_policy_attachment" "validate_basic" {
  role       = aws_iam_role.validate_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "trigger_basic" {
  role       = aws_iam_role.trigger_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
