# check the variables.tf for description
# project setting
project_name   = "44"
environment    = "lab"
developer_name = "jade"

# aws config
aws_region = "seoul"
## for running terraform
aws_profile = "prod-44lab"
## route53
origin_domain_name = "44lab"
# CICD config
slack = {
  workspace_id          = ""
  notify_channel_id     = ""
  notify_all_channel_id = ""
}
## this config for test. If production set to false
## Target resource is s3 and ecr
force_destroy = false
# some region does not support. seoul region does not support ecr api end point on az-d.
# exclude_ecr_api_end_point_region_name = [""]