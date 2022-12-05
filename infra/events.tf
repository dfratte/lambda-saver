resource "aws_cloudwatch_event_rule" "lambda_saver_event_rule" {
  schedule_expression = "cron(0 9,18 ? * MON-FRI *)"
  name                = "lambdaSaver-event-rule"
  description         = "An event rule for triggering Lambda Saver"
}

resource "aws_cloudwatch_event_target" "lambda_saver_check_at_rate" {
  rule = aws_cloudwatch_event_rule.lambda_saver_event_rule.name
  arn  = aws_lambda_function.lambda_saver_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_saver" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_saver_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_saver_event_rule.arn
}