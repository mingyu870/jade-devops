output "ec2" {
  value = aws_instance.ec2
}

output "key_pair_file_path" {
  value = local_file.ec2_db_mysql_key
}

output "key_pair_pem" {
  value     = tls_private_key.rsa.private_key_pem
  sensitive = true
}

output "sg" {
  value = aws_security_group.ec2_sg
}

