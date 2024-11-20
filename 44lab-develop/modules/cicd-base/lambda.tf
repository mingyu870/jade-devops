##############################
# ECS - change event - lambda
##############################

resource "aws_lambda_function" "notification_function" {
  function_name = "${var.full_proj_name}-notification-function"
  
  s3_bucket        = "llg-production-terraform-s3"  
  s3_key           = "lambda-ecs_function.zip"   
  handler          = "lambda/task.handler" 
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30

  description      = "ECS task state change events and sends notifications to Slack."

  environment {
    variables = {
      GOOGLE_CHAT_HOOK_URL = var.google_chat_hook_url
    }
  }
}

##############################
# IAM Roles and Policies
##############################

# EventBridge IAM Role
resource "aws_iam_role" "lambda_event_role" {
  name = "${var.full_proj_name}-lambda-eventbridge-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_policy" {
  name = "${var.full_proj_name}-eventbridge-Policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["events:*"],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "event_role_policy_attachment" {
  role       = aws_iam_role.lambda_event_role.name
  policy_arn = aws_iam_policy.eventbridge_policy.arn
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.full_proj_name}-lambda-Role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.full_proj_name}-lambda-Policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "sns:Publish",
          "logs:*"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::llg-production-terraform-s3/*",
          "arn:aws:sns:*:*:llg-production-event-alarm-topic",
          "arn:aws:sns:*:*:llg-production-rds-alarm-topic",
          "arn:aws:sns:*:*:llg-production-resource-alarm-topic",
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

##############################
# SNS Topic and Subscription
##############################

resource "aws_sns_topic" "resource_alarm_topic" {
  name = "${var.full_proj_name}-resource-alarm-topic"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.resource_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notification_function.arn

  depends_on = [aws_lambda_permission.sns_allow]
}

resource "aws_lambda_permission" "sns_allow" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.resource_alarm_topic.arn
}

##############################
# EventBridge Rule and Target
##############################

resource "aws_cloudwatch_event_rule" "ecs_task_state_change" {
  name        = "${var.full_proj_name}-ecs-task-state-change"
  description = "Trigger Lambda function for ECS Task State Change events"

  event_pattern = jsonencode({
    source       = ["aws.ecs"],
    detail-type  = ["ECS Task State Change"],
    detail       = {
      lastStatus = ["STOPPED", "PENDING", "RUNNING"]
    }
  })

  event_bus_name = "default"
  state          = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_task_event_target" {
  rule = aws_cloudwatch_event_rule.ecs_task_state_change.name
  arn  = aws_sns_topic.resource_alarm_topic.arn
}

resource "aws_lambda_permission" "eventbridge_allow" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_task_state_change.arn
}

##############################
# CloudWatch target group google lambda
##############################

resource "aws_lambda_function" "target_function" {
  function_name = "${var.full_proj_name}-target-function"
  
  s3_bucket        = "llg-production-terraform-s3"  
  s3_key           = "lambda-target_function.zip"   
  handler          = "lambda/health.handler"  
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30

  description      = "ELB Target group Unhealthy Error slack."

  environment {
    variables = {
      GOOGLE_CHAT_HOOK_URL = var.google_chat_hook_url_2
    }
  }
}

resource "aws_sns_topic_subscription" "lambda_subscription_terget" {
  topic_arn = aws_sns_topic.resource_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.target_function.arn
}

resource "aws_lambda_permission" "allow_sns" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.target_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.resource_alarm_topic.arn
}


##############################
# codepipeline - change event - lambda
##############################

resource "aws_lambda_function" "pipeline_function" {
  function_name = "${var.full_proj_name}-pipeline_function"
  
  s3_bucket        = "llg-production-terraform-s3"  
  s3_key           = "lambda-pipeline_function.zip"   
  handler          = "lambda/pipeline.handler" 
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30

  description      = "pipeline state change events and sends notifications."

  environment {
    variables = {
      GOOGLE_CHAT_HOOK_URL   = "https://chat.googleapis.com/v1/spaces/AAAAwuYoF9k/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=_9wEB9N6hDTLPzv45fUhBAAucq2kRPJHas1TKwr-quA"
    }
  }
}


resource "aws_sns_topic_subscription" "existing_lambda_subscription" {
  topic_arn = aws_sns_topic.resource_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.pipeline_function.arn
}

resource "aws_lambda_permission" "existing_sns_allow" {
  statement_id  = "AllowExecutionFromExistingSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pipeline_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.resource_alarm_topic.arn
}


resource "aws_cloudwatch_event_rule" "pipeline_state_change" {
  name        = "${var.full_proj_name}-pipeline-state-change"
  description = "Trigger Lambda function for pipeline State Change events"

  event_pattern = jsonencode({
    source       = ["aws.codepipeline"],
    detail-type  = ["CodePipeline Pipeline Execution State Change"],
    detail       = {
      lastStatus = ["STARTED", "SUCCEEDED", "FAILED"]
    }
  })

  event_bus_name = "default"
  state          = "ENABLED"
}

resource "aws_cloudwatch_event_target" "pipeline_event_target" {
  rule = aws_cloudwatch_event_rule.pipeline_state_change.name
  arn  = aws_lambda_function.pipeline_function.arn 
}

resource "aws_lambda_permission" "eventbridg_allow" {
  statement_id  = "AllowExecutionFromEventBridg"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pipeline_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pipeline_state_change.arn
}

##############################
# cloudwatch - change event - lambda
##############################

resource "aws_lambda_function" "cloudwatch_function" {
  function_name = "${var.full_proj_name}-cloudwatch_function"
  
  s3_bucket        = "llg-production-terraform-s3"  
  s3_key           = "lambda-cloudwatch_function.zip"   
  handler          = "lambda/cloudwatch.handler" 
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30

  description      = "cloudwatch state change events and sends notifications."

  environment {
    variables = {
      GOOGLE_CHAT_HOOK_URL = var.google_chat_hook_url_2
    }
  }
}

resource "aws_sns_topic_subscription" "existings_lambda_subscription" {
  topic_arn = aws_sns_topic.resource_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.cloudwatch_function.arn
}

resource "aws_lambda_permission" "existings_sns_allow" {
  statement_id  = "AllowExecutionFromExistingSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.resource_alarm_topic.arn
}

resource "aws_cloudwatch_event_rule" "cloudwatch_state_change" {
  name        = "${var.full_proj_name}-cloudwatch-state-change"
  description = "Trigger Lambda function for cloudwatch State Change events"

  event_pattern = jsonencode({
    source       = ["aws.cloudwatch"],
    detail-type  = ["CloudWatch Alarm State Change"]
  })

  event_bus_name = "default"
  state          = "ENABLED"
}


resource "aws_cloudwatch_event_target" "cloudwatch_event_target" {
  rule = aws_cloudwatch_event_rule.cloudwatch_state_change.name
  arn  = aws_lambda_function.cloudwatch_function.arn 
}

resource "aws_lambda_permission" "eventbrid_allow" {
  statement_id  = "AllowExecutionFromEventBrid"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_state_change.arn
}

##############################
# RDS instance - event alarm
##############################

resource "aws_lambda_function" "rdsinstance_function" {
  function_name = "${var.full_proj_name}-rdsinstance_function"
  
  s3_bucket        = "llg-production-terraform-s3"  
  s3_key           = "lambda-rdsinstance_function.zip"
  handler          = "lambda/instancerds.handler" 
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30

  description      = "RDS instance event alarm to google chat"

  environment {
    variables = {
      GOOGLE_CHAT_HOOK_URL = var.google_chat_hook_url
    }
  }
}

resource "aws_sns_topic_subscription" "lambda_subscription_instances" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.rdsinstance_function.arn
}

resource "aws_lambda_permission" "intance_allow_sns" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rdsinstance_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

##############################
# RDS instance - Deadlock alarm
##############################

# Lambda 함수 생성
resource "aws_lambda_function" "deadlock_function" {
  function_name = "${var.full_proj_name}-deadlock_function"
  
  s3_bucket        = "llg-production-terraform-s3"  
  s3_key           = "lambda-deadlock_function.zip"
  handler          = "lambda/deadlock.handler" 
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30

  description      = "RDS deadlock event alarm to google chat"

  environment {
    variables = {
      GOOGLE_CHAT_HOOK_URL = var.google_chat_hook_url
    }
  }
}

##############################
# SNS Topic Subscription (Lambda 연결을 위해)
##############################
resource "aws_sns_topic_subscription" "deadlock-lambda_subscription" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.deadlock_function.arn
}

# Lambda Permission 추가 (SNS가 Lambda를 호출할 수 있도록)
resource "aws_lambda_permission" "deadlock-allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deadlock_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

# CloudWatch 이벤트 규칙 생성 (RDS 데드락 이벤트)
resource "aws_cloudwatch_event_rule" "deadlock_event" {
  name          = "deadlock-event-rule"
  event_pattern = jsonencode({
    source = ["aws.rds"],
    "detail-type" = ["RDS DB Instance Event"],
    detail = {
      Message = ["Deadlock found"]
    }
  })
}

# CloudWatch 이벤트 규칙과 Lambda 함수 연결
resource "aws_cloudwatch_event_target" "deadlock_target" {
  rule      = aws_cloudwatch_event_rule.deadlock_event.name
  target_id = "deadlock_lambda"
  arn       = aws_lambda_function.deadlock_function.arn
}

# Lambda Permission 추가 (CloudWatch Events가 Lambda를 호출할 수 있도록)
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deadlock_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.deadlock_event.arn
}
