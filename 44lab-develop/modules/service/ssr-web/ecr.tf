resource "aws_ecr_repository" "ssr_web" {
  name         = "${var.full_proj_name}-${var.module_name}"
  force_delete = var.force_destroy

  tags = {
    Name = "${var.full_proj_name}-${var.full_proj_name}-ecr_repository"
  }
}