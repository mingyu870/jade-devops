# Security group for database
To access RDS from another module, provide the `security group id` and `rds port` information of RDS to that module, and set the options to access the RDS connection module in each module as follows.

```hcl
module "another_module" {
  ## ...another information
  rds_security_group_id       = module.mysql.rds_sg.id
  rds_port                    = module.mysql.rds.port
}

resource "aws_vpc_security_group_ingress_rule" "allow_to_rds_connect" {
  security_group_id = var.rds_security_group_id

  description                  = "Allow another module"
  from_port                    = var.rds_port
  to_port                      = var.rds_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.another_module.id
}

```
