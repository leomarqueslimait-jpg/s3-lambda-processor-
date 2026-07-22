# The container
resource "aws_api_gateway_rest_api" "form" {
  name        = "${var.project_name}-form-api"
  description = "${var.project_name} student enrollment form API"
}

# URL path/endpoint
resource "aws_api_gateway_resource" "submit" {
  rest_api_id = aws_api_gateway_rest_api.form.id
  parent_id   = aws_api_gateway_rest_api.form.root_resource_id
  path_part   = "submit"
}

# POST method
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.form.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "POST"
  authorization = "NONE"
}

# OPTIONS method for CORS preflight
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.form.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# POST integration - calls Lambda
resource "aws_api_gateway_integration" "lambda_post" {
  rest_api_id             = aws_api_gateway_rest_api.form.id
  resource_id             = aws_api_gateway_resource.submit.id
  integration_http_method = "POST"
  http_method             = aws_api_gateway_method.post.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.form_api.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_options" {
  rest_api_id = aws_api_gateway_rest_api.form.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.form.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# OPTIONS method response - tells the browser which CORS headers to expect
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.form.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.form.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.lambda_options]
}

# Permission — allows API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.form_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.form.execution_arn}/*/POST/submit"
}

# Deployment - locks in the current API configuration
resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.form.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.submit,
      aws_api_gateway_method.post,
      aws_api_gateway_method.options,
      aws_api_gateway_integration.lambda_post,
      aws_api_gateway_integration.lambda_options,
      aws_api_gateway_method_response.options_200,
      aws_api_gateway_method_response.post_200,
      aws_api_gateway_integration_response.options,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.lambda_options, aws_api_gateway_integration.lambda_post]
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.form.id
  stage_name    = "prod"
}
