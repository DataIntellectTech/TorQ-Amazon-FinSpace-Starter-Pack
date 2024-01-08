{
  "Comment": "A description of my state machine",
  "StartAt": "create_cluster_on_schedule",
  "States": {
    "create_cluster_on_schedule": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${create_cluster_on_schedule_func_arn}"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "BackoffRate": 2,
          "MaxAttempts": 1
        }
      ],
      "End": true,
      "Catch": [
        {
          "ErrorEquals": [
            "ConflictException"
          ],
          "Next": "onConflict_error"
        },
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "other_error"
        }
      ]
    },
    "onConflict_error": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${onConflict_error_func_arn}"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "BackoffRate": 2,
          "MaxAttempts": 1
        }
      ],
      "End": true,
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "other_error"
        }
      ]
    },
    "other_error": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${other_error_func_arn}"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Next": "store_And_Notify"
    },
    "store_And_Notify": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${store_notify_topic_arn}",
        "Message.$": "$"
      },
      "End": true,
      "InputPath": "$.Message"
    } 
  }
}