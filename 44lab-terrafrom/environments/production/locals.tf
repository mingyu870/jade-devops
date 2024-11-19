
locals {
##############################
# RDS local set
##############################
  mysql_spec = {
    instance_type    = "db.t3.medium"
  }

# EC2-1 spec setup
  bastion_spec = {
    instance_type      = "t2.micro"
    ami                = "ami-0c5303379cc3cc927" # Amazon Linux 2023 AMI seoul region
    exclude_subnet_azs = []
    ingress_rules = {
      office_wifi_http = {
        description = "office-http"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      office_wifi_ssh = {
        description = "office-ssh"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
    }
  }
}