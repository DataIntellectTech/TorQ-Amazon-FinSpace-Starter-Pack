
### create SNS and SNS topic ###

## create SNS itself

resource "aws_sns_topic" "lambda_error_topic" {
  name = "${var.lambda-name}-${var.region}-errors-topic"
}

## create subscription for SQS

resource "aws_sns_topic_subscription" "lambda_error_queue_target" {
  topic_arn = aws_sns_topic.lambda_error_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.lambda_error_queue.arn
}

## create subscription for email

resource "aws_sns_topic_subscription" "lambda_error_email_target" {
  count = var.send-sns-alert ? 1 : 0
  topic_arn = aws_sns_topic.lambda_error_topic.arn
  protocol = "email"
  endpoint = "eugene.temlock@dataintellect.com"
  #endpoint = var.alert-smpt-target
}


### SQS ###

data "aws_iam_policy_document" "lambda_error_queue_access_policy_doc" {
  statement {
    effect = "Allow"

    principals {
        type = "AWS"
        identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    actions = ["sqs:*"]
    resources = [aws_sqs_queue.lambda_error_queue.arn]
  }

  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.lambda_error_queue.arn]

    condition {
      test = "ArnEquals"
      variable = "aws:SourceArn"
      values = [aws_sns_topic.lambda_error_topic.arn]
    }
  }
}

resource "aws_sqs_queue" "lambda_error_queue" {
    name = "${var.lambda-name}-${var.region}-errorQueue"
    message_retention_seconds = 1209600
}

resource "aws_sqs_queue_policy" "lambda_error_queue_access_policy" {
    queue_url = aws_sqs_queue.lambda_error_queue.id
    policy = data.aws_iam_policy_document.lambda_error_queue_access_policy_doc.json
}


