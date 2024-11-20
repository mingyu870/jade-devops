##############################
# iam role
##############################
resource "aws_iam_role" "chatbot_role" {
  name = "${var.full_proj_name}-ChatBot-Channel-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "codepipeline_chatbot_trigger" {
  name = "${var.full_proj_name}-Chatbot-NotificationsOnly-Policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "resource_explorer_read_only" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = data.aws_iam_policy.AWSResourceExplorerReadOnlyAccess.arn
}

resource "aws_iam_role_policy_attachment" "chatbot_trigger" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = aws_iam_policy.codepipeline_chatbot_trigger.arn
}

##############################
# chatbot
##############################
resource "aws_sns_topic" "sns-topic" {
  name = "${var.full_proj_name}-sns-topic"
}

data "aws_iam_policy_document" "topic-policy" {
  statement {
    sid     = "1"
    actions = ["SNS:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "codestar-notifications.amazonaws.com"
      ]
    }

    resources = [aws_sns_topic.sns-topic.arn]
  }
}

resource "aws_sns_topic_policy" "alerts_ci_slack_notifications_sns_topic_policy" {
  arn    = aws_sns_topic.sns-topic.arn
  policy = data.aws_iam_policy_document.topic-policy.json
}


resource "awscc_chatbot_slack_channel_configuration" "slack-notify" {
  provider           = awscc.cc
  configuration_name = "${var.full_proj_name}-slack-notify"
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  slack_channel_id   = var.slack.notify_channel_id
  slack_workspace_id = var.slack.workspace_id
  guardrail_policies = [data.aws_iam_policy.ReadOnlyAccess.arn]
  sns_topic_arns     = [aws_sns_topic.sns-topic.arn]
  logging_level      = "INFO" //fixme <=== debuging ... will be delete
  lifecycle {
    // fixme manual will be delete when tf apply. If donot wanna manual delete use ignore changes
    ignore_changes = [sns_topic_arns]
  }
}

# sns topic all
resource "aws_sns_topic" "sns-all-topic" {
  name = "${var.full_proj_name}-sns-all-topic"
}

data "aws_iam_policy_document" "all-topic-policy" {
  statement {
    sid     = "1"
    actions = ["SNS:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "codestar-notifications.amazonaws.com"
      ]
    }

    resources = [aws_sns_topic.sns-all-topic.arn]
  }
}


resource "aws_sns_topic_policy" "alerts_ci_slack_notifications_all_sns_topic_policy" {
  arn    = aws_sns_topic.sns-all-topic.arn
  policy = data.aws_iam_policy_document.all-topic-policy.json
}


// fixme delete start
output "topic-all" {
  value = aws_sns_topic.sns-all-topic
}


// fixme delete end

resource "awscc_chatbot_slack_channel_configuration" "slack-all-notify" {
  provider           = awscc.cc
  configuration_name = "${var.full_proj_name}-slack-notify-all"
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  slack_channel_id   = var.slack.notify_all_channel_id
  slack_workspace_id = var.slack.workspace_id
  guardrail_policies = [data.aws_iam_policy.ReadOnlyAccess.arn]
  sns_topic_arns     = [aws_sns_topic.sns-all-topic.arn]
  logging_level      = "INFO" //fixme <=== debuging ... will be delete
  lifecycle {
    // fixme manual will be delete when tf apply. If donot wanna manual delete use ignore changes
    ignore_changes = [sns_topic_arns]
  }
}
