
variable "environment-id" {
  description = "import the environment_id"
}

variable "sfn_state_machine_arn" {
  description = "step function state machine to create clusters"
}

variable "eventBridge_role_arn" {
  description = "IAM role allowing eventBrige to execute step functions"
}

variable "create-mfilters" {
  description = "flag to create metric filters on wdb log groups"
}

variable "wdb_log_groups" {
  type        = list
  description = "list of log groups with prefix 'wdb'"
}

variable "alarm_pattern" {
  description = "string pattern that will increase a counter when found"
}

data "aws_cloudwatch_log_groups" "aws_log_groups" {
  log_group_name_prefix = "/aws/vendedlogs/finspace/${var.environment-id}/wdb"
}

locals {
    metric-filter-name = "wdb_eop_shutdown_msg"
    log-prefix         = "/aws/vendedlogs/finspace/${var.environment-id}"
    wdb_log_groups     = [for name in var.wdb_log_groups: name if contains(data.aws_cloudwatch_log_groups.aws_log_groups.log_group_names,"${local.log-prefix}/${name}")]
}

data "aws_cloudwatch_log_group" "wdb_log_groups" {
  for_each   = var.create-mfilters ? toset(local.wdb_log_groups) : toset([])
  name       = "${local.log-prefix}/${each.value}"
}

resource "aws_cloudwatch_log_metric_filter" "wdb_log_monit" {
    for_each       = var.create-mfilters ? toset(local.wdb_log_groups) : toset([])
    name           = local.metric-filter-name
    pattern        = var.alarm_pattern
    log_group_name = data.aws_cloudwatch_log_group.wdb_log_groups[each.value].name

    metric_transformation {
        name          = "count_eopMsg_wdb"
        namespace     = "AWSFinTorq"
        value         = "1" 
        default_value = "0"
        unit          = "Count"
    } 
}

resource "aws_cloudwatch_metric_alarm" "wdb_log_monit_alarm" {
  count = (var.create-mfilters ? length(local.wdb_log_groups) : 0) > 0 ? 1 : 0
  alarm_name = "${local.metric-filter-name}_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "count_eopMsg_wdb"
  namespace =   "AWSFinTorq"
  period = 120
  statistic = "Sum"
  threshold = 1
  alarm_description = "This alarm should raise if ${local.metric-filter-name} metric filter finds any matches"
  datapoints_to_alarm = 1
}

resource "aws_cloudwatch_event_rule" "wdb_log_monit_rule" {
  count = (var.create-mfilters ? length(local.wdb_log_groups) : 0) > 0 ? 1 : 0
  name = "${local.metric-filter-name}_rule"
  description = "trigger lambda when ${local.metric-filter-name} finds any matches"

  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "resources": ["${aws_cloudwatch_metric_alarm.wdb_log_monit_alarm[0].arn}"]
    "detail": {
      "state": {
        "value": ["ALARM"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "wdb_log_monit_rule_target" {
  count = (var.create-mfilters ? length(local.wdb_log_groups) : 0) > 0 ? 1 : 0
  arn = var.sfn_state_machine_arn
  rule = aws_cloudwatch_event_rule.wdb_log_monit_rule[0].name
  role_arn = var.eventBridge_role_arn
    input = jsonencode({
    cluster_prefix = "hdb",
    clusterType = "HDB"
  })
}
