
#############
output "sns_topic_slack_notify" {
  value = aws_sns_topic.sns-topic
}

output "sns_topic_slack_all_notify" {
  value = aws_sns_topic.sns-all-topic
}
output "codepipeline_artifact_bucket" {
  value = aws_s3_bucket.codepipeline_artifact_bucket
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