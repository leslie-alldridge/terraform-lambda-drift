terraform {
  backend "local" {}
}

provider "aws" {
  region = "ap-southeast-2"
}

data "archive_file" "lambda_script" {
  type        = "zip"
  source_file = "${path.module}/script.py"
  output_path = "${path.module}/zipped/script.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "${path.module}/zipped/script.zip"
  function_name    = "terraform_lambda_drift"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "script.say_hello"
  source_code_hash = data.archive_file.lambda_script.output_base64sha256
  runtime          = "python3.10"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "terraform-lambda-drift"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
