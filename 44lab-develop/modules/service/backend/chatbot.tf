# notify setting
resource "aws_codestarnotifications_notification_rule" "backend-notify" {
  detail_type    = "FULL"
  event_type_ids = local.notify_events
  name           = "${var.full_proj_name}-${var.module_name}-notify"
  resource       = aws_codepipeline.backend.arn

  target {
    address = var.chatbot_slack_notify_config_arn
    type    = "AWSChatbotSlack"
  }
}

resource "aws_codestarnotifications_notification_rule" "backend-notify-all" {
  detail_type    = "FULL"
  event_type_ids = local.notify_all_events
  name           = "${var.full_proj_name}-${var.module_name}-notify-all"
  resource       = aws_codepipeline.backend.arn

  target {
    address = var.chatbot_slack_all_notify_config_arn
    type    = "AWSChatbotSlack"
  }
}

locals {
  notify_events = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-stage-execution-failed"
  ]
  notify_all_events = [
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-failed"
  ]
}
