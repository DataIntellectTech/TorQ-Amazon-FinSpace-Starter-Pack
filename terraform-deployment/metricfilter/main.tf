
// 1. you'll need to create a metric filter to monitor the appropriate cloudwatch log group
//      it would be ideal if we could import the cloudwatch log group inform
// 2. will probably need a for-each block and count to create one metric filter per wdb log group
// 3. create an alarm for each metric filter
// 4. create an eventbridge rule for each alarm. The alarms must hit the step function defined in the "lambda" module

// when the wdb triggers an eop, does the hdb need to know which wdb to subscribe to 
//  

variable "environment-id" {
  description = "import the environment_id"
}

locals {
    metric-filter-name = "wdb_eop_shutdown_msg"
    log-group-prefix      = "/aws/vendedlogs/finspace/${var.environment-id}"
}


resource "aws_cloudwatch_log_metric_filter" "wdb_log_monit" {
    for_each       = toset(["wdb","wdb2"])
    name           = local.metric-filter-name
    pattern        = "kill the hdb"             ##hard coded for now, but eventually this should be a configurable variable
    log_group_name = "${local.log-group-prefix}/${each.value}"

    metric_transformation {
        name          = "count_eopMsg_wdb"
        namespace     = "AWSFinTorq"
        value         = "1" 
        default_value = "0"
        unit          = "Count"
    } 
}

resource "aws_cloudwatch_metric_alarm" "wdb_log_monit_alarm" {
  alarm_name = "${local.metric-filter-name}_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = aws_cloudwatch_log_metric_filter.wdb_log_monit["wdb"].metric_transformation[0].name
  namespace =   aws_cloudwatch_log_metric_filter.wdb_log_monit["wdb"].metric_transformation[0].namespace
  period = 120
  statistic = "Sum"
  threshold = 1
  alarm_description = "This alarm should raise if ${local.metric-filter-name} metric filter finds any matches"
  datapoints_to_alarm = 1
}

resource "aws_cloudwatch_event_rule" "wdb_log_monit_rule" {
  name = "${local.metric-filter-name}_rule"
  description = "trigger lambda when ${local.metric-filter-name} finds any matches"

  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "resources": ["${aws_cloudwatch_metric_alarm.wdb_log_monit_alarm.arn}"]
    "detail": {
      "state": {
        "value": ["ALARM"]
      }
    }
  })
}



/*
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



