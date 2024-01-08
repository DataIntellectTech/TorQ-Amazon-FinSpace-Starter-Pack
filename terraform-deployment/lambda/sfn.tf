variable "sfn-machine-name" {
  description = "name of your step functions machine"
}

### create the appropriate IAM roles

## step function assume role doc
data "aws_iam_policy_document" "assume_states_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

## eventBridge assume role doc
data "aws_iam_policy_document" "assume_events_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
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
            aws_lambda_function.finSpace-rdb-onConflict-lambda.arn,
            aws_lambda_function.finSpace-rdb-errorFormat-lambda.arn
        ]
    }

}

## sns policies
data "aws_iam_policy_document" "sns_publish_scoped_access_policy_doc" {
  statement {
    effect = "Allow"

    actions = ["sns:Publish"]

    resources = [aws_sns_topic.lambda_error_topic.arn]
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

## eventBridge policies
data "aws_iam_policy_document" "eventBridge_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "states:StartExecution"
    ]
    resources = [aws_sfn_state_machine.sfn_state_machine.arn]
  }
}

resource "aws_iam_policy" "lambda_invoke_scoped_access_policy" {
    name = "${var.sfn-machine-name}-${var.region}-lambdaInvoke-policy"
    policy = data.aws_iam_policy_document.lambda_invoke_scoped_access_policy_doc.json
}

resource "aws_iam_policy" "sns_publish_scoped_access_policy" {
    name = "${var.sfn-machine-name}-${var.region}-snsPublish-policy"
    policy = data.aws_iam_policy_document.sns_publish_scoped_access_policy_doc.json
}

resource "aws_iam_policy" "xray_scoped_access_policy" {
    name = "${var.sfn-machine-name}-${var.region}-xray-policy"
    policy = data.aws_iam_policy_document.xray_scoped_access_policy_doc.json
}

resource "aws_iam_role" "states_execution_role" {
  name = "StepFunctions-${var.sfn-machine-name}-${var.region}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_states_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_invoke_scoped_access_policy" {
    role = aws_iam_role.states_execution_role.name
    policy_arn = aws_iam_policy.lambda_invoke_scoped_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_sns_publish_scoped_access_policy" {
    role = aws_iam_role.states_execution_role.name
    policy_arn = aws_iam_policy.sns_publish_scoped_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_xray_scoped_access_policy" {
    role = aws_iam_role.states_execution_role.name
    policy_arn = aws_iam_policy.xray_scoped_access_policy.arn
}

resource "aws_iam_policy" "eventBridge_policy" {
    name =  "schedule-${var.sfn-machine-name}-${var.region}-policy"
    policy = data.aws_iam_policy_document.eventBridge_policy_doc.json
}

resource "aws_iam_role" "eventBridge_role" {
    name = "schedule-${var.sfn-machine-name}-${var.region}-role"
    assume_role_policy = data.aws_iam_policy_document.assume_events_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_eventBridge_policy" {
    role = aws_iam_role.eventBridge_role.name
    policy_arn = aws_iam_policy.eventBridge_policy.arn
}


### sfn function ###

resource "aws_sfn_state_machine" "sfn_state_machine" {
    name = "${var.sfn-machine-name}-${var.region}"
    role_arn = aws_iam_role.states_execution_role.arn

    definition = templatefile("${path.module}/bin/sfn_state_machine_cfg.tpl",{
        create_cluster_on_schedule_func_arn = aws_lambda_function.finSpace-rdb-lambda.arn
        onConflict_error_func_arn           = aws_lambda_function.finSpace-rdb-onConflict-lambda.arn
        other_error_func_arn                = aws_lambda_function.finSpace-rdb-errorFormat-lambda.arn
        store_notify_topic_arn              = aws_sns_topic.lambda_error_topic.arn
    })
}

#### create the eventbrighe scheduler ####

resource "aws_cloudwatch_event_rule" "rotateRDB_eventRule" {
  name = "rotateRDB_eventRule_${var.region}"
  description = "Scheduler to create a new RDB every two hours"
  schedule_expression = "cron(0 */2 ? * 2-6 2024)" 
}

resource "aws_cloudwatch_event_target" "onRotateRDB_target" {
  arn = aws_sfn_state_machine.sfn_state_machine.arn
  rule = aws_cloudwatch_event_rule.rotateRDB_eventRule.name
  role_arn = aws_iam_role.eventBridge_role.arn
    input = jsonencode({
    cluster_prefix = "rdb",
    clusterType = "RDB"
  })
}

resource "aws_cloudwatch_event_rule" "rotateWDB_eventRule" {
  name = "rotateWDB_eventRule_${var.region}"
  description = "Scheduler to create a new WDB every two hours"
  schedule_expression = "cron(5 */2 ? * 2-6 2024)"
}

resource "aws_cloudwatch_event_target" "onRotateWDB_target" {
  arn = aws_sfn_state_machine.sfn_state_machine.arn
  rule = aws_cloudwatch_event_rule.rotateWDB_eventRule.name
  role_arn = aws_iam_role.eventBridge_role.arn
    input = jsonencode({
    cluster_prefix = "wdb",
    clusterType = "RDB"
  })
}