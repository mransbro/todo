resource "aws_apigatewayv2_api" "lambda" {
  name          = "ToDo"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "todo" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.todo.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /todos"
  target    = "integrations/${aws_apigatewayv2_integration.todo.id}"
}


resource "aws_apigatewayv2_route" "get-id" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /todos/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.todo.id}"
}


resource "aws_apigatewayv2_route" "put" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "PUT /todos"
  target    = "integrations/${aws_apigatewayv2_integration.todo.id}"
}


resource "aws_apigatewayv2_route" "delete" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "DELETE /todos/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.todo.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}