variable "sfn-machine-name" {
  description = "name of your step functions machine"
}

### create the appropriate roles lambda_execution_role

data "aws_iam_policy_document" "assume_sfn_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

## lambda policies
data "aws_iam_policy_document" "lambda_invoke_scoped_access_policy_doc" {
    statement {
        effect = "Allow"

        actions = ["lambda:InvokeFunction"]

        resources = [
            aws_lambda_function.finSpace-rdb-lambda.arn,
            aws_lambda_function.finSpace-rdb-onConflict-lambda.arn
        ]
    }

}

## sqs policies
data "aws_iam_policy_document" "sqs_sendMsg_scoped_access_policy_doc" {
  statement {
    effect = "Allow"

    actions = ["sqs:SendMessage"]

    resources = [aws_sqs_queue.lambda_error_queue.arn]
  }
}

## xray policies - may be optional
data "aws_iam_policy_document" "xray_scoped_access_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_invoke_scoped_access_policy" {
    name = "${var.sfn-machine-name}-${var.region}-lambdaInvoke-policy"
    policy = data.aws_iam_policy_document.lambda_invoke_scoped_access_policy_doc.json
}

resource "aws_iam_policy" "sqs_sendMsg_scoped_access_policy" {
    name = "${var.sfn-machine-name}-${var.region}-sqsSendMsg-policy"
    policy = data.aws_iam_policy_document.sqs_sendMsg_scoped_access_policy_doc.json
}

resource "aws_iam_policy" "xray_scoped_access_policy" {
    name = "${var.sfn-machine-name}-${var.region}-xray-policy"
    policy = data.aws_iam_policy_document.xray_scoped_access_policy_doc.json
}

resource "aws_iam_role" "states_execution_role" {
  name = "StepFunctions-${var.sfn-machine-name}-${var.region}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_sfn_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_invoke_scoped_access_policy" {
    role = aws_iam_role.states_execution_role.name
    policy_arn = aws_iam_policy.lambda_invoke_scoped_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_sqs_sendMsg_scoped_access_policy" {
    role = aws_iam_role.states_execution_role.name
    policy_arn = aws_iam_policy.sqs_sendMsg_scoped_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_xray_scoped_access_policy" {
    role = aws_iam_role.states_execution_role.name
    policy_arn = aws_iam_policy.xray_scoped_access_policy.arn
}

### sfn function here we go ###

resource "aws_sfn_state_machine" "sfn_state_machine" {
    name = "${var.sfn-machine-name}-${var.region}"
    role_arn = aws_iam_role.states_execution_role.arn

    definition = templatefile("${path.module}/bin/sfn_state_machine_cfg.tpl",{
        create_cluster_on_schedule_func_arn = aws_lambda_function.finSpace-rdb-lambda.arn
        onConflict_error_func_arn           = aws_lambda_function.finSpace-rdb-onConflict-lambda.arn
        other_error_queue_url               = aws_sqs_queue.lambda_error_queue.url
    })
}
