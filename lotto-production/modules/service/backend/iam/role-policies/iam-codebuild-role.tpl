{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid" : "CodebuildCloudwatchLog",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ],
      "Resource": [
        "arn:aws:logs:${data_aws_region}:${data_aws_current_id}:log-group:${data_codebuild_log_group_name}",
        "arn:aws:logs:${data_aws_region}:${data_aws_current_id}:log-group:${data_codebuild_log_group_name}:*"
      ]
    },
    {
      "Sid": "CodebuildReportGroup",
      "Effect": "Allow",
      "Action": [
        "codebuild:UpdateReport",
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:BatchPutTestCases",
        "codebuild:BatchPutCodeCoverages"
      ],
      "Resource": [
        "arn:aws:codebuild:${data_aws_region}:${data_aws_current_id}:report-group/${data_codebuild_name}-*"
      ]
    },
    {
      "Sid": "CodepipelineArtifactS3Storage",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:GetObject",
        "s3:GetBucketLocation",
        "s3:GetBucketAcl"
      ],
      "Resource": [
            "${data_s3_bucket_codepipeline_arn}",
            "${data_s3_bucket_codepipeline_arn}/*"
      ]
    },
    {
      "Sid": "LoadDotenvFileForBuild",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
            "${data_s3_bucket_dotenv_arn}",
            "${data_s3_bucket_dotenv_arn}/*"
      ]
    },
    {
      "Sid": "UploadDockerImageToECR",
      "Effect": "Allow",
      "Action": [
        "ecr:UploadLayerPart",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Resource": "${data_ecr_arn}"
    },
    {
      "Sid": "GetAuthorizationToken",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    }
  ]
}