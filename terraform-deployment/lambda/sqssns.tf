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

data "aws_iam_policy_document" "lambda_sqs_destination_policy_doc" {
  statement {
    effect = "Allow"

    actions = ["sqs:SendMessage"]

    resources = [aws_sqs_queue.lambda_error_queue.arn]
  }
}

resource "aws_iam_policy" "lambda_sqs_destination_policy" {
  name = "${var.lambda-name}-${var.region}-sqs-destination-role"

  policy = data.aws_iam_policy_document.lambda_sqs_destination_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_sqs_destination" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sqs_destination_policy.arn
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
