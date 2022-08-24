// Lambda Fucntion role to get file form S3 bucket
// and Publish logs to CloudWatch

resource "aws_iam_role" "demicon_get_state_lambda_role" {
  
  name = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = var.iam_policy_name
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "s3:GetObject",
          Effect = "Allow",
          Resource = join("", ["arn:aws:s3:::", var.arbitrary_terraform_state_bucket, "/*"])
        },
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = "arn:aws:logs:*:*:*",
          Effect   = "Allow"
        }
      ]
    })
  }
}

// A Lambda Fucntion that allows to retrieve an arbitrary terraform state file
// from S3 and return terraform outputs from the state file

resource "aws_lambda_function" "demicon_get_state_lambda" {
  function_name    = var.lambda_name
  handler          = "index.handler"
  runtime          = "python3.9"
  timeout          = 30
  filename         = "lambda-snippets/demicon-get-state-lambda-code.zip"
  source_code_hash = filebase64sha256("lambda-snippets/demicon-get-state-lambda-code.zip")
  role             = aws_iam_role.demicon_get_state_lambda_role.arn
  memory_size      = 128
}