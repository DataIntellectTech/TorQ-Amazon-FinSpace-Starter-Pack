### Secondary Lambda ####

locals {
  lambda-secondary-file-name = "create_cluster_onConflict"
  lambda-secondary-name      = "${var.lambda-name}-onConflict"
}

data "aws_iam_policy_document" "lambda_secondary_basic_execution" {
  statement {
    effect = "Allow"

    actions = ["logs:CreateLogGroup"]

    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${local.lambda-secondary-name}:*"]
  }
}

data "aws_iam_policy_document" "lambda_lambda_destination_policy_doc" {
  statement {
    effect = "Allow"

    actions = ["lambda:InvokeFunction"]

    resources = [aws_lambda_function.finSpace-rdb-onConflict-lambda.arn]
  }
}

resource "aws_iam_policy" "lambda_secondary_basic_policy" {
  name = "${local.lambda-secondary-name}-${var.region}-basic-permissions-role"

  policy = data.aws_iam_policy_document.lambda_secondary_basic_execution.json
}

resource "aws_iam_policy" "lambda_lambda_destination_policy" {
  name = "${var.lambda-name}-${var.region}-lambda-destination-role"

  policy = data.aws_iam_policy_document.lambda_lambda_destination_policy_doc.json
}

resource "aws_iam_role" "lambda_secondary_execution_role" {
  name = "${local.lambda-secondary-name}-role-${var.region}"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_secondary_1" {
  role = aws_iam_role.lambda_secondary_execution_role.name
  policy_arn = aws_iam_policy.lambda_secondary_basic_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_secondary_2" {
  role = aws_iam_role.lambda_secondary_execution_role.name
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_secondary_3" {
  role = aws_iam_role.lambda_secondary_execution_role.name
  policy_arn = aws_iam_policy.lambda_finspace_policy.arn
}

resource "aws_lambda_function" "finSpace-rdb-onConflict-lambda" {
  filename = data.archive_file.lambda_my_function.output_path
  function_name = local.lambda-secondary-name
  handler = "${local.lambda-secondary-file-name}.lambda_handler"
  role = aws_iam_role.lambda_secondary_execution_role.arn

  runtime = "python3.11"
  timeout = 900
}

resource "aws_iam_role_policy_attachment" "attach_lambda_destination" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_lambda_destination_policy.arn
}

