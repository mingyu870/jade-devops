##############################
# buckets
##############################

# service storage
resource "aws_s3_bucket" "service_storage" {
  bucket        = "${var.full_proj_name}-service-storage"
  force_destroy = var.force_destroy

  tags = {
    Name = "service_storage"
  }
}

resource "aws_s3_bucket_public_access_block" "service_storage_acl" {
  bucket = aws_s3_bucket.service_storage.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "service_storage_policy" {
  depends_on = [
    aws_s3_bucket_public_access_block.service_storage_acl,
    aws_s3_bucket.service_storage
  ]
  bucket = aws_s3_bucket.service_storage.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : "${aws_s3_bucket.service_storage.arn}/*",
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "service_storage_s3_kms" {
  depends_on = [aws_s3_bucket_policy.service_storage_policy]
  bucket     = aws_s3_bucket.service_storage.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# s3 access logs
resource "aws_s3_bucket" "s3_access_logs" {
  bucket        = "${var.full_proj_name}-s3-access-logs"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_log_s3_kms" {
  bucket = aws_s3_bucket.s3_access_logs.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "access_log_policy" {
  bucket = aws_s3_bucket.s3_access_logs.id
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
        "Resource" : "${aws_s3_bucket.s3_access_logs.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket" "terraform_s3" {
  bucket        = "${var.full_proj_name}-terraform-s3"
  force_destroy = var.force_destroy
}
