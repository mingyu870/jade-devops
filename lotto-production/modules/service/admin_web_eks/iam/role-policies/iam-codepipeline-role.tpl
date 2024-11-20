{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*",
      "Condition": {
        "StringEqualsIfExists": {
          "iam:PassedToService": [
            "cloudformation.amazonaws.com",
            "elasticbeanstalk.amazonaws.com",
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:UploadArchive",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:GetRepository",
        "codecommit:GetCommit",
        "codecommit:GetBranch",
        "codecommit:CancelUploadArchive"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:GetDeployment",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetApplication",
        "codedeploy:CreateDeployment"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "codestar-connections:UseConnection",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:*",
        "sns:*",
        "s3:*",
        "rds:*",
        "elasticloadbalancing:*",
        "elasticbeanstalk:*",
        "ecs:*",
        "ec2:*",
        "cloudwatch:*",
        "cloudformation:*",
        "autoscaling:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:ListFunctions",
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "opsworks:UpdateStack",
        "opsworks:UpdateApp",
        "opsworks:DescribeStacks",
        "opsworks:DescribeInstances",
        "opsworks:DescribeDeployments",
        "opsworks:DescribeCommands",
        "opsworks:DescribeApps",
        "opsworks:CreateDeployment"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:ValidateTemplate",
        "cloudformation:UpdateStack",
        "cloudformation:SetStackPolicy",
        "cloudformation:ExecuteChangeSet",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeChangeSet",
        "cloudformation:DeleteStack",
        "cloudformation:DeleteChangeSet",
        "cloudformation:CreateStack",
        "cloudformation:CreateChangeSet"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:StartBuildBatch",
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds",
        "codebuild:BatchGetBuildBatches"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "devicefarm:ScheduleRun",
        "devicefarm:ListProjects",
        "devicefarm:ListDevicePools",
        "devicefarm:GetUpload",
        "devicefarm:GetRun",
        "devicefarm:CreateUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "servicecatalog:UpdateProduct",
        "servicecatalog:ListProvisioningArtifacts",
        "servicecatalog:DescribeProvisioningArtifact",
        "servicecatalog:DeleteProvisioningArtifact",
        "servicecatalog:CreateProvisioningArtifact"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "cloudformation:ValidateTemplate",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecr:DescribeImages",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "states:StartExecution",
        "states:DescribeStateMachine",
        "states:DescribeExecution"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "appconfig:StopDeployment",
        "appconfig:StartDeployment",
        "appconfig:GetDeployment"
      ],
      "Resource": "*"
    }
  ]
}