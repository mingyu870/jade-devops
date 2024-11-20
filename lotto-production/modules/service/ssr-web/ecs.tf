
resource "aws_ecs_service" "ssr_web" {
  depends_on = [aws_lb_target_group.ssr_web]

  name            = local.ecs_service_name
  cluster         = var.admin_web_ecs_cluster.id
  task_definition = aws_ecs_task_definition.ssr_web.arn
  desired_count   = var.ecs_options.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = values({ for k, v in var.private_subnet : k => v.id })
    security_groups = [aws_security_group.ecs_ssr_web_services.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ssr_web.arn
    container_name   = aws_ecr_repository.ssr_web.name
    container_port   = var.service_port
  }

  lifecycle {
    # If task definition changed then do not use 'ignore_changes' that time
    ignore_changes = [task_definition]
  }
}

locals {
  ecs_healthCheck_option_sample = {
    command = [
      "CMD-SHELL",
      "node healthCheck.js || exit 1"
    ],
    "interval"  = 30
    "timeout"   = 5
    "retries"   = 3
    description = "Most health check like that. Project includes file `healthCheck.js` and also fix `healthCheck.js`'s port number on project"
  }
}

resource "aws_ecs_task_definition" "ssr_web" {
  family = "${var.module_name}-family"
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  # The Unit for each number is MiB 1024MiB = 1GB
  cpu                      = var.ecs_options.cpu
  memory                   = var.ecs_options.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      # name은 container name과 동일하게 설정
      name  = aws_ecr_repository.ssr_web.name
      image = "${aws_ecr_repository.ssr_web.repository_url}:latest"
      portMappings = [
        {
          containerPort = var.ecs_options.service_port
          hostPort      = var.ecs_options.service_port
        }
      ],
      logConfiguration = {
        logDriver : "awslogs"
        options : {
          awslogs-create-group : "true"
          awslogs-group : "/ecs/${var.admin_web_ecs_cluster.name}/${local.ecs_service_name}"
          awslogs-region : var.aws_region
          awslogs-stream-prefix : "ecs"
        },
      },

      healthCheck = var.ecs_options.healthCheck
    }
  ])
}


#########  autoscale  IAM  

resource "aws_iam_role" "ecs_autoscale" {
  name = "${var.full_proj_name}-${var.module_name}-ecs-autoscale-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Autoscaling",
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_autoscale_policy" {
  name        = "${var.full_proj_name}-${var.module_name}-ecs-autoscale-policy"
  description = "Custom policy for ECS autoscaling"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "application-autoscaling:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_policy_attachment" {
  role      = aws_iam_role.ecs_autoscale.name
  policy_arn = aws_iam_policy.ecs_autoscale_policy.arn
}

resource "aws_appautoscaling_target" "ecs_target" {
  min_capacity        = 2
  max_capacity        = 4
  resource_id         = "service/${var.admin_web_ecs_cluster.name}/${aws_ecs_service.ssr_web.name}"
  role_arn            = aws_iam_role.ecs_autoscale.arn  
  scalable_dimension  = "ecs:service:DesiredCount"
  service_namespace   = "ecs"

  depends_on = [
    aws_ecs_service.ssr_web
  ]
  lifecycle {
    ignore_changes = [role_arn]
  }
}

#########  autoscale policy 

resource "aws_appautoscaling_policy" "ecs_policy_scale_out" {
  name               = "scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "PercentChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment         = 50
    }
  }
}

### scale-in set
resource "aws_appautoscaling_policy" "ecs_policy_scale_in" {
  name               = "scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "PercentChangeInCapacity"
    cooldown                = 60  # Cooldown period in seconds
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment         = -50
    }
  }
}

######### ECS container Cloudwatch Alert
## scale_out set
resource "aws_cloudwatch_metric_alarm" "cpu_alert_scale_out" {
  alarm_name                = "${var.admin_web_ecs_cluster.name}-cpu-alert-scale-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 20
  datapoints_to_alarm       = 2
  insufficient_data_actions = []
  alarm_actions             = ["arn:aws:sns:ap-southeast-1:961341522940:llg-production-resource-alarm-topic", aws_appautoscaling_policy.ecs_policy_scale_out.arn]

  metric_query {
    id          = "cpualert"
    expression  = "mm1m0 * 100 / mm0m0"
    return_data = "true"
  }

  metric_query {
    id = "mm1m0"

    metric {
      metric_name = "CpuUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.admin_web_ecs_cluster.name
        ServiceName = aws_ecs_service.ssr_web.name
      }
    }
  }

  metric_query {
    id = "mm0m0"

    metric {
      metric_name = "CpuReserved"
      namespace   = "ECS/ContainerInsights"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.admin_web_ecs_cluster.name
        ServiceName = aws_ecs_service.ssr_web.name
      }
    }
  }
}

# ## scale_in set

resource "aws_cloudwatch_metric_alarm" "cpu_alert_scale_in" {
  alarm_name                = "${var.admin_web_ecs_cluster.name}-cpu-alert-scale-in"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 70
  datapoints_to_alarm       = 2
  insufficient_data_actions = []
  alarm_actions             = ["arn:aws:sns:ap-southeast-1:961341522940:llg-production-resource-alarm-topic", aws_appautoscaling_policy.ecs_policy_scale_in.arn]

  metric_query {
    id          = "cpualert"
    expression  = "mm1m0 * 100 / mm0m0"
    return_data = "true"
  }

  metric_query {
    id = "mm1m0"

    metric {
      metric_name = "CpuUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.admin_web_ecs_cluster.name
        ServiceName = aws_ecs_service.ssr_web.name
      }
    }
  }

  metric_query {
    id = "mm0m0"

    metric {
      metric_name = "CpuReserved"
      namespace   = "ECS/ContainerInsights"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.admin_web_ecs_cluster.name
        ServiceName = aws_ecs_service.ssr_web.name
      }
    }
  }
}
