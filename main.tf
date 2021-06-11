#-------------------------------------------------
#--- ROLE
#-------------------------------------------------
resource "aws_iam_role" "iam_s3_lambda_event_trigger" {
  name                = "iam_s3_lambda_event_trigger"
  managed_policy_arns = [aws_iam_policy.bucket-a.arn, aws_iam_policy.bucket-b.arn]
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

#-------------------------------------------------
#--- POLICY-A
#-------------------------------------------------
resource "aws_iam_policy" "bucket-a" {
  name        = "bucket-a-read-access-policy"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${local.bucket-a-name}/*"
      },
    ]
  })
}

#-------------------------------------------------
#--- POLICY-B
#-------------------------------------------------
resource "aws_iam_policy" "bucket-b" {
  name        = "bucket-b-read-access-policy"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:putObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${local.bucket-b-name}/*"
      },
    ]
  })
}

#-------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
resource "aws_lambda_permission" "allow_bucket" {
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  =  aws_lambda_function.func.arn
  principal      = "s3.amazonaws.com"
  source_arn     =  aws_s3_bucket.bucket-a.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "func" {
  filename       = "lambda/platform-engineer-test-lambda.zip"
  function_name  = "platform-engineer-test-lambda"
  role           =  aws_iam_role.iam_s3_lambda_event_trigger.arn
  handler        = "platform-engineer-test-lambda.lambda_handler"
  runtime        = "python3.8"
}

resource "aws_s3_bucket" "bucket-a" {
  bucket         = local.bucket-a-name
}

resource "aws_s3_bucket" "bucket-b" {
  bucket         = local.bucket-b-name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket         = aws_s3_bucket.bucket-a.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events = [
      "s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket]
}

#-------------------------------------------------
#--- IAM USERS & POLICIES
#-------------------------------------------------
resource "aws_iam_user" "user-a" {
  name   = "user-a"
}

resource "aws_iam_user_policy" "policy-user-a" {
  name   = "policy-user-a"
  user   = aws_iam_user.user-a.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:putObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.bucket-a-name}/*"
    }
  ]
}
EOF
}

#~~~~~~~~~~~~~~~~~~~

resource "aws_iam_user" "user-b" {
  name   = "user-b"
}

resource "aws_iam_user_policy" "policy-user-b" {
  name   = "policy-user-b"
  user   = aws_iam_user.user-b.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.bucket-b-name}/*"
    }
  ]
}
EOF
}

