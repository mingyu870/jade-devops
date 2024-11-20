{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ecr:*",
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "ecrPermission"
    },
    {
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "cloudwatchPermission"
    }
  ]
}