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
}

resource "aws_sqs_queue" "lambda_error_queue" {
    name = "${var.lambda-name}-${var.region}-errorQueue"
    message_retention_seconds = 1209600
}

resource "aws_sqs_queue_policy" "lambda_error_queue_access_policy" {
    queue_url = aws_sqs_queue.lambda_error_queue.id
    policy = data.aws_iam_policy_document.lambda_error_queue_access_policy_doc.json
}


## create an SNS topic to poll SQS
