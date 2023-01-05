data "archive_file" "lambda_todo" {
  type = "zip"

  source_dir  = "${path.module}/todo"
  output_path = "${path.module}/todo.zip"
}

resource "aws_s3_object" "lambda_todo" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "todo.zip"
  source = data.archive_file.lambda_todo.output_path

  etag = filemd5(data.archive_file.lambda_todo.output_path)
}

resource "aws_lambda_function" "todo" {
  function_name = "ToDo"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_todo.key

  runtime = "go1.x"
  handler = "todo.handler"

  source_code_hash = data.archive_file.lambda_todo.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "todo" {
  name = "/aws/lambda/${aws_lambda_function.todo.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}