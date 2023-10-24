
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

    resources = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"]
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
        "ec2:DeleteVpcEndpoints",
        "ec2:CreateTags"
    ]

    resources = ["arn:aws:ec2:${var.region}:${var.account_id}:vpc-endpoint/*"]
  }

  statement {
    effect = "Allow"

    actions = [
        "ec2:DescribeTags",
        "ec2:DescribeSubnets"
    ]

    resources = ["*"]
  }
}

## put it all together

resource "aws_iam_role" "lambda_execution_role" {
  name = "boto3-rdb-scaling-test"
  assume_role_policy = data.aws_iam_policy_document.assume_role_doc.json
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    data.aws_iam_policy_document.lambda_basic_execution.arn,
    data.aws_iam_policy_document.ec2-permissions-lambda.arn,
    data.aws_iam_policy_document.finspace-extra.arn,
  ])

  role = aws_iam_role.lambda_execution_role.name
  policy_arn = each.value
}


#### create lambda function itself ####

## create the scripts
##      I don't know how the scripts get attached and stuff

data "archive_file" "lambda_my_function" {
  type             = "zip"
  source_dir      = "${path.module}/src"
  output_file_mode = "0666"
  output_path      = "${path.module}/bin/delete_cluster_on_alarm.zip"
}

resource "aws_lambda_function" "finSpace-rdb-lambda" {
  filename = data.archive_file.lambda_my_function.output_path
  function_name = var.lambda-name
  handler = "boto3-rdb-scaling-test.lambda_handler"
  role = aws_iam_role.lambda_execution_role.arn

  runtime = "python3.9"
  timeout = 900
}

#### create the alarm ####
resource "aws_cloudwatch_metric_alarm" "RDBOverCPUUtilization" {
  alarm_name = "terraform-rdb-cpu-test-1"
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
    "resources": ["arn:aws:cloudwatch:us-east-1:766012286003:alarm:terraform-rdb-cpu-test-1"],
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
  statementid = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.finSpace-rdb-lambda.name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.trigger_finSpace-rdb-lambda.arn
}


output {

}