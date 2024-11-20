# code pipeline
resource "aws_s3_bucket" "codepipeline_artifact_bucket" {
  bucket        = "${var.full_proj_name}-codepipeline-artifact"
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.full_proj_name}-codepipeline-artifact"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_s3_kms" {
  bucket = aws_s3_bucket.codepipeline_artifact_bucket.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}