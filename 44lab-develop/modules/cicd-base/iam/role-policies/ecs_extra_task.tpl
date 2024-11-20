{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid": "AllowSESEmailSend",
      "Effect":"Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource":"*"
    },
    {
        "Sid": "S3ServiceStorageFileUpDownload",
        "Effect": "Allow",
        "Action": [
            "s3:Get*",
            "s3:List*",
            "s3:Describe*",
            "s3:DeleteObject",
            "s3:PutObject*"
        ],
        "Resource": [
            "${data_s3_service_bucket_arn}",
            "${data_s3_service_bucket_arn}/*"
        ]
    }
  ]
}