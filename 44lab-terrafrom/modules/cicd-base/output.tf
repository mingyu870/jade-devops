output "codepipeline_bucket" {
  value = aws_s3_bucket.codepipeline_artifact_bucket
}

output "codestar" {
  value = aws_codestarconnections_connection.github_connection
}

output "ecs_task_role_arn" {
  value = {
    task_role           = aws_iam_role.ecs_task_role.arn
    task_execution_role = aws_iam_role.ecs_task_execution_role.arn
  }
}

output "chatbot_slack_notify" {
  value = awscc_chatbot_slack_channel_configuration.slack-notify
}

output "chatbot_slack_all_notify" {
  value = awscc_chatbot_slack_channel_configuration.slack-all-notify
}

#############
output "sns_topic_slack_notify" {
  value = aws_sns_topic.sns-topic
}

output "sns_topic_slack_all_notify" {
  value = aws_sns_topic.sns-all-topic
}

##############

output "codepipeline_artifact_bucket" {
  value = aws_s3_bucket.codepipeline_artifact_bucket
}

### ECS Cluster 분리 
output "admin_web_ecs_cluster" {
  value = aws_ecs_cluster.admin_web_ecs_cluster
}

output "admin_api_ecs_cluster" {
  value = aws_ecs_cluster.admin_api_ecs_cluster
}

output "member_api_ecs_cluster" {
  value = aws_ecs_cluster.member_api_ecs_cluster
}

output "ecs_task_role" {
  value = aws_iam_role.ecs_task_role
}

output "ecs_task_execution_role" {
  value = aws_iam_role.ecs_task_execution_role
}

# Outputs
output "topic_alarm" {
  value = aws_sns_topic.event_alarm_topic.arn
}

output "event_rule_name" {
  value = aws_cloudwatch_event_rule.event.name
}

output "event_target_id" {
  value = aws_cloudwatch_event_target.target.id
}

output "resource_alarm_topic_arn" {
  value = aws_sns_topic.resource_alarm_topic.arn
}

output "resource_alarm_topic_name" {
  value = aws_sns_topic.resource_alarm_topic.name
}