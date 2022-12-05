resource "aws_lambda_function" "lambda_saver_function" {
  filename         = "../build/main.zip"
  function_name    = "lambdaSaver"
  handler          = "main"
  role             = aws_iam_role.lambda_saver_execution_role.arn
  runtime          = "go1.x"
  source_code_hash = filebase64sha256("../build/main.zip")
}