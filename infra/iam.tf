resource "aws_iam_role" "lambda_saver_execution_role" {
  name               = "LambdaSaverExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}

data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_saver_execution_role_policy_attachment" {
  role       = aws_iam_role.lambda_saver_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_saver_ec2_policy" {
  name        = "LambdaSaverEC2Policy"
  path        = "/"
  description = "A policy for EC2 operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:StopInstances",
          "ec2:StartInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_saver_policy_attachment" {
  role       = aws_iam_role.lambda_saver_execution_role.name
  policy_arn = aws_iam_policy.lambda_saver_ec2_policy.arn
}
