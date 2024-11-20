##############################
# buckets
##############################
# dotenv
resource "aws_s3_bucket" "dotenv" {
  bucket        = "${var.full_proj_name}-dotenv"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dotenv_s3_kms" {
  bucket = aws_s3_bucket.dotenv.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# labdma.zip 
resource "aws_s3_bucket" "lambda" {
  bucket        = "${var.full_proj_name}-lambda"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_s3_kms" {
  bucket = aws_s3_bucket.lambda.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "logging_dotenv" {
  depends_on = [aws_s3_bucket.s3_access_logs]
  bucket     = aws_s3_bucket.dotenv.id

  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "${aws_s3_bucket.dotenv.id}/"

  target_object_key_format {
    simple_prefix {}
  }
}

resource "aws_s3_bucket_versioning" "dotenv_versioning" {
  bucket = aws_s3_bucket.dotenv.id
  versioning_configuration {
    status = "Enabled"
  }
}

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


############################################################################
# terraform backend server
resource "aws_s3_bucket" "terraform_backend" {
  bucket        = "${var.full_proj_name}-terraform-backend-s3"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_backend_s3_kms" {
  bucket = aws_s3_bucket.terraform_backend.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "logging_terraform_backend" {
  depends_on = [aws_s3_bucket.s3_access_logs]
  bucket     = aws_s3_bucket.terraform_backend.id

  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "${aws_s3_bucket.terraform_backend.id}/"

  target_object_key_format {
    simple_prefix {}
  }
}

resource "aws_s3_bucket_versioning" "terraform_backend_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}
