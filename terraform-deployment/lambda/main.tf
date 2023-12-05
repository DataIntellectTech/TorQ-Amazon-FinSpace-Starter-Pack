
variable "lambda-name" {
  description = "import name of the function"
  type = string
}

variable "region" {
  description = "import the aws region"
}

variable "environment-id" {
  description = "import the environment_id"
}

variable "account_id" {
  description = "import the account_id of the current root user"
}

locals {
  lambda-file-name = "delete_cluster_on_alarm"
}

#### create and attach the appropriate IAM policies ####

## basic lambda execution permissions

data "aws_iam_policy_document" "assume_role_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_basic_execution" {
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

    resources = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.lambda-name}:*"]
  }
}


## finspace policies

data "aws_iam_policy_document" "finspace-extra" {

  statement {
    effect = "Allow"

    actions = [
        "finspace:DeleteKxCluster",
        "finspace:CreateKxCluster",
        "finspace:GetKxCluster"
    ]

    resources = ["arn:aws:finspace:${var.region}:${var.account_id}:kxEnvironment/${var.environment-id}/kxCluster/*"]
  }

  statement {
    effect = "Allow"

    actions = ["finspace:MountKxDatabase"]

    resources = ["arn:aws:finspace:${var.region}:${var.account_id}:kxEnvironment/${var.environment-id}/kxDatabase/*"]
  }
}

## ec2 policies
data "aws_iam_policy_document" "ec2-permissions-lambda" {

  statement {
    effect = "Allow"

    actions = [
        "ec2:DescribeTags",
        "ec2:DescribeSubnets",
        "ec2:CreateTags",
        "ec2:DescribeVpcs",
        "logs:CreateLogDelivery"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeVpcEndpointServicePermissions",
      "ec2:DeleteVpcEndpoints",
      "ec2:CreateVpcEndpoint"
    ]

    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:vpc-endpoint-service/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:security-group/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:subnet/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:vpc/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:vpc-endpoint/*",
      "arn:aws:ec2:${var.region}:${var.account_id}:route-table/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:AssociateVPCWithHostedZone"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }
}


## put it all together

resource "aws_iam_policy" "lambda_ec2_policy" {
  name = "${var.lambda-name}-ec2-permissions-role"

  policy = data.aws_iam_policy_document.ec2-permissions-lambda.json
}

resource "aws_iam_policy" "lambda_basic_policy" {
  name = "${var.lambda-name}-basic-permissions-role"

  policy = data.aws_iam_policy_document.lambda_basic_execution.json
}

resource "aws_iam_policy" "lambda_finspace_policy" {
  name = "${var.lambda-name}-finspace-permissions-role"

  policy = data.aws_iam_policy_document.finspace-extra.json
}


resource "aws_iam_role" "lambda_execution_role" {
  name = "boto3-rdb-scaling-test"
  assume_role_policy = data.aws_iam_policy_document.assume_role_doc.json
}

resource "aws_iam_role_policy_attachment" "attach1" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_basic_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach2" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach3" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_finspace_policy.arn
}

#resource "aws_iam_role_policy_attachment" "role-policy-attachment" {

#  for_each = toset([
#    aws_iam_policy.lambda_basic_policy.arn,
#    aws_iam_policy.lambda_ec2_policy.arn,
#    aws_iam_policy.lambda_finspace_policy.arn,
#  ])

#  role = aws_iam_role.lambda_execution_role.name
#  policy_arn = each.value
#}


#### create lambda function itself ####

## create the scripts
##      I don't know how the scripts get attached and stuff

data "archive_file" "lambda_my_function" {
  type             = "zip"
  source_dir      = "${path.module}/src"
  output_file_mode = "0666"
  output_path      = "${path.module}/bin/${var.lambda-name}.zip"
}

resource "aws_lambda_function" "finSpace-rdb-lambda" {
  filename = data.archive_file.lambda_my_function.output_path
  function_name = var.lambda-name
  handler = "${local.lambda-file-name}.lambda_handler"
  role = aws_iam_role.lambda_execution_role.arn

  runtime = "python3.11"
  timeout = 900
}

#### create the alarm ####
resource "aws_cloudwatch_metric_alarm" "RDBOverCPUUtilization" {
  alarm_name = "trigger-${var.lambda-name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/FinSpace"
  period = 60
  statistic = "Maximum"
  threshold = 10
  alarm_description = "This alarm should be raised if rdb is over a certain threshold"
  datapoints_to_alarm = 1

  dimensions = {
    KxClusterId = "rdb"
  }
}

#### create the evenBridge event ####

resource "aws_cloudwatch_event_rule" "trigger_finSpace-rdb-lambda" {
  name = "trigger-boto3-rdb-scaling-test"
  description = "trigger lambda when CPUUtilization exceeds threshold"

  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "resources": ["${aws_cloudwatch_metric_alarm.RDBOverCPUUtilization.arn}"]
    "detail": {
      "state": {
        "value": ["ALARM"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "target_finSpace-rdb-lambda" {
  arn = aws_lambda_function.finSpace-rdb-lambda.arn
  rule = aws_cloudwatch_event_rule.trigger_finSpace-rdb-lambda.name
}

resource "aws_lambda_permission" "lambda_from_cw_permission" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.finSpace-rdb-lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.trigger_finSpace-rdb-lambda.arn
}

output "execution_policy_res" {
  value = data.aws_iam_policy_document.lambda_basic_execution.json
}