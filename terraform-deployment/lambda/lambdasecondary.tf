### Secondary Lambda ####

locals {
  lambda-onConflict-file-name  = "create_cluster_onConflict"
  lambda-onConflict-name       = "${var.lambda-name}-onConflict"
  lambda-errorFormat-file-name = "error_formatter"
  lambda-errorFormat-name      = "${var.lambda-name}-errorFormatting" 
}

### onConflict lambda ### 

resource "aws_iam_role" "lambda_onConflict_execution_role" {
  name = "${local.lambda-onConflict-name}-role-${var.region}"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_basic_to_onConflict" {
  role = aws_iam_role.lambda_onConflict_execution_role.name
  policy_arn = aws_iam_policy.lambda_basic_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy_to_onConflict" {
  role = aws_iam_role.lambda_onConflict_execution_role.name
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_finspace_policy_to_onConflict" {
  role = aws_iam_role.lambda_onConflict_execution_role.name
  policy_arn = aws_iam_policy.lambda_finspace_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy_to_onConflict" {
  role = aws_iam_role.lambda_onConflict_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_lambda_function" "finSpace-rdb-onConflict-lambda" {
  filename = data.archive_file.lambda_my_function.output_path
  function_name = local.lambda-onConflict-name
  handler = "${local.lambda-onConflict-file-name}.lambda_handler"
  role = aws_iam_role.lambda_onConflict_execution_role.arn

  runtime = "python3.11"
  timeout = 900
}

### errorFormatting lambda ###

resource "aws_iam_role" "lambda_errorFormat_execution_role" {
  name = "${local.lambda-errorFormat-name}-role-${var.region}"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_basic_to_errorFormat" {
  role = aws_iam_role.lambda_errorFormat_execution_role.name
  policy_arn = aws_iam_policy.lambda_basic_policy.arn
}

resource "aws_lambda_function" "finSpace-rdb-errorFormat-lambda" {
  filename = data.archive_file.lambda_my_function.output_path
  function_name = local.lambda-errorFormat-name
  handler = "${local.lambda-errorFormat-file-name}.lambda_handler"
  role = aws_iam_role.lambda_errorFormat_execution_role.arn

  runtime = "python3.11"
  timeout = 900
}
