# The `aws_codestarconnections_connection` resource create with `PENDING` state.
# Authentication with the connection provider must be completed in the AWS Console.
# See the AWS documentation(https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html) for details.

locals {
  connection_name_trimmed = substr("${var.full_proj_name}-github-connection", 0, 32)
  connection_name         = replace(local.connection_name_trimmed, "/-$/", "")
}

resource "aws_codestarconnections_connection" "github_connection" {
  # Member must have length less than or equal to 32
  name          = local.connection_name
  provider_type = "GitHub"

  tags = {
    Name = local.connection_name
  }
}
