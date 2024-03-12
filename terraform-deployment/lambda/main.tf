
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

variable "s3-bucket-id" {
  description = "name of code bucket"
}

variable "s3-data-bucket-id" {
  description = "name of data bucket"
}

variable "rdbCntr_mod" {
  description = "maximum number of rdbs created by lambda"
}

variable "send-sns-alert" {
  description = "flag to send sns emails or not"
}

variable "alert-smpt-target" {
  description = "email address to send sns alerts to. only used if send-alert set to 'true'"
}

locals {
  lambda-file-name = "create_cluster_on_alarm"
}

#### create and attach the appropriate IAM policies ####

## basic lambda execution permissions

data "aws_iam_policy_document" "assume_lambda_doc" {
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

    resources = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.lambda-name}*:*"]
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

    resources = ["arn:aws:finspace:${var.region}:${var.account_id}:kxEnvironment/*/kxCluster/*"]
  }

  statement {
    effect = "Allow"

    actions = ["finspace:MountKxDatabase"]

    resources = ["arn:aws:finspace:${var.region}:${var.account_id}:kxEnvironment/*/kxDatabase/*"]
  }

  statement {
    effect = "Allow"

    actions = ["finspace:ListKxClusters"]

    resources = ["arn:aws:finspace:${var.region}:${var.account_id}:kxEnvironment/*"]
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
        "logs:CreateLogDelivery",
        "logs:DescribeLogGroups",
        "logs:GetLogDelivery",
        "logs:ListLogDeliveries",
        "logs:DescribeResourcePolicies",
        "logs:PutResourcePolicy",
        "logs:UpdateLogDelivery"
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

## s3 policies

data "aws_iam_policy_document" "s3-permissions-lambda" {

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging"
    ]

    resources = [
      "arn:aws:s3:::${var.s3-bucket-id}",
      "arn:aws:s3:::${var.s3-bucket-id}/*",
      "arn:aws:s3:::${var.s3-data-bucket-id}",
      "arn:aws:s3:::${var.s3-data-bucket-id}/*"
    ]
  }
}

## put it all together

resource "aws_iam_policy" "lambda_ec2_policy" {
  name = "${var.lambda-name}-${var.region}-ec2-permissions-role"

  policy = data.aws_iam_policy_document.ec2-permissions-lambda.json
}

resource "aws_iam_policy" "lambda_basic_policy" {
  name = "${var.lambda-name}-${var.region}-basic-permissions-role"

  policy = data.aws_iam_policy_document.lambda_basic_execution.json
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "${var.lambda-name}-${var.region}-s3-permissions-role"

  policy = data.aws_iam_policy_document.s3-permissions-lambda.json
}

resource "aws_iam_policy" "lambda_finspace_policy" {
  name = "${var.lambda-name}-${var.region}-finspace-permissions-role"

  policy = data.aws_iam_policy_document.finspace-extra.json
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.lambda-name}-role-${var.region}"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_doc.json
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

resource "aws_iam_role_policy_attachment" "attach4" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
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

resource "local_file" "lambda_configs" {
  content = <<-EOT
    envId="${var.environment-id}"
    rdbCntr_modulo=${var.rdbCntr_mod}
  EOT
  filename = "${path.module}/src/env.py"
}

data "archive_file" "lambda_my_function" {
  depends_on = [local_file.lambda_configs]

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

/*
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
*/

output "execution_policy_res" {
  value = data.aws_iam_policy_document.lambda_basic_execution.json
}