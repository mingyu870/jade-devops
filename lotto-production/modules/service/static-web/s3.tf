# s3 distribution
resource "aws_s3_bucket" "distribution" {
  bucket        = "${var.full_proj_name}-${var.module_name}--static-web-distribution"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_policy" "allow_from_cloudfront" {
  bucket = aws_s3_bucket.distribution.id
  policy = data.aws_iam_policy_document.allow_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_from_cloudfront" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.distribution.arn}/*"]
    actions   = ["s3:GetObject"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.cf_distribution.arn}"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kms" {
  bucket = aws_s3_bucket.distribution.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# web access logs
resource "aws_s3_bucket" "web_access_logs" {
  bucket        = "${var.full_proj_name}-${var.module_name}--static-web-access-logs"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_log_s3_kms" {
  bucket = aws_s3_bucket.web_access_logs.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "access_log_policy" {
  bucket = aws_s3_bucket.web_access_logs.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "S3AccessLogPolicy",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logging.s3.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.web_access_logs.arn}/*"
      }
    ]
  })
}
