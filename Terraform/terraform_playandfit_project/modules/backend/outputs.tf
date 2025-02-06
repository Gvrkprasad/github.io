output "lambda_fn_arn" {
  value = aws_lambda_function.frontend.arn
}

output "api_url" {
  value = aws_apigatewayv2_stage.api_stage.invoke_url
}

output "ex_arn" {
  value = aws_apigatewayv2_api.api_http.execution_arn
}