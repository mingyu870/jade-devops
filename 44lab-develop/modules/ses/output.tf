#######################
# output
#######################

output "ses_domain_valid" {
  value     = aws_sesv2_email_identity.domain
  sensitive = true
}

output "ses_owen" {
  value = {
    tokens  = aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens
    tokens1 = aws_sesv2_email_identity.domain.dkim_signing_attributes.*.tokens
    #     verify_dkim = aws_route53_record.verify_dkim
  }

  #   value = aws_sesv2_email_identity.owen_email
  sensitive = true
}
