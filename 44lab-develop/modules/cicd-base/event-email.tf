##############################
# IAM Role
##############################
resource "aws_iam_role" "event_role" {
  name = "${var.full_proj_name}-eventbridge-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "eventbridge_trigger" {
  name = "${var.full_proj_name}-eventbridge-NotificationsOnly-Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "events:*",
          "pipes:*"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "resource_read_only" {
  role       = aws_iam_role.event_role.name
  policy_arn = data.aws_iam_policy.AWSResourceExplorerReadOnlyAccess.arn
}

resource "aws_iam_role_policy_attachment" "eventbridge_trigger" {
  role       = aws_iam_role.event_role.name
  policy_arn = aws_iam_policy.eventbridge_trigger.arn
}

##############################
# SNS Topic and Subscription
##############################

resource "aws_sns_topic" "event_alarm_topic" {
  name = "${var.full_proj_name}-event-alarm-topic"
}
/* # e-mail address sending 
resource "aws_sns_topic_subscription" "email_subscription_jade" {
  topic_arn = aws_sns_topic.event_alarm_topic.arn
  protocol  = "email"
  endpoint  = "jade@kpxdx.com"
} */

data "aws_iam_policy_document" "alarm_topic_policy" {
  statement {
    sid     = "1"
    actions = ["SNS:Publish","SNS:Subscribe"]

    principals {
      type        = "Service"
      identifiers = [
        "sns.amazonaws.com",
        "events.amazonaws.com"  # Allow EventBridge to publish
      ]
    }

    resources = [aws_sns_topic.event_alarm_topic.arn]
  }
}

resource "aws_sns_topic_policy" "alarm_topic_policy" {
  arn    = aws_sns_topic.event_alarm_topic.arn
  policy = data.aws_iam_policy_document.alarm_topic_policy.json
}


##############################
# EventBridge - CodePipeline - Email Setup
##############################

resource "aws_cloudwatch_event_rule" "event" {
  name        = "${var.full_proj_name}-codepipeline-alarm"
  description = "${var.full_proj_name}-codepipeline-alarm"

  event_pattern = jsonencode({
    source       = ["aws.codepipeline"]
    detail-type  = ["CodePipeline Stage Execution State Change"]
    detail       = {
      state = ["STARTED", "SUCCEEDED", "FAILED"]
    }
  })

  event_bus_name = "default"
  state          = "ENABLED"
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.event.name
  arn  = aws_sns_topic.event_alarm_topic.arn

  input_transformer {
    input_paths = {
      account   = "$.account"
      pipeline  = "$.detail.pipeline"
      region    = "$.region"
      source    = "$.detail-type"
      stage     = "$.detail.stage"
      state     = "$.detail.state"
      timestamp = "$.time"
    }

    input_template = <<EOF
"The Pipeline <pipeline> state."
"######################################"

"Source : <pipeline>"
"Account : <account>"
"Region : <region>"
"Stage : <stage>"
"State : <state>"
EOF
  }
}

# Data sources for dynamic values
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}