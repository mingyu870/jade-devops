##############################
# IAM Role and Policy
##############################
resource "aws_iam_role" "backup_role" {
  name = "backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  role      = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

##############################
# Backup Vault
##############################
resource "aws_backup_vault" "mysql-vol" {
  name = "mysql-vol"
  tags = {
    Name = "mysql-vol-backup-vault"
  }
}

##############################
# Backup Plan
##############################
resource "aws_backup_plan" "daily_backup" {
  name = "daily-backup-plan"

  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.mysql-vol.name
    schedule          = "cron(18 0 * * ? *)" 

  lifecycle {
    cold_storage_after = 30  # Move to cold storage after 30 days
    delete_after       = 120  # Delete backups after 60 days
    }
  }
}

##############################
# Backup Selection
##############################
resource "aws_backup_selection" "mysql_vol" {
  name          = "mysql-vol-backup-selection"
  plan_id       = aws_backup_plan.daily_backup.id
  iam_role_arn  = aws_iam_role.backup_role.arn

  selection_tag {
    key   = "Name"
    value = "mysql-vol"
    type  = "STRINGEQUALS"  # Ensure this type is supported; adjust if necessary
  }
}


