output "backup_vault_arn" {
  value = aws_backup_vault.mysql-vol.arn
}

output "backup_plan_id" {
  value = aws_backup_plan.daily_backup.id
}
