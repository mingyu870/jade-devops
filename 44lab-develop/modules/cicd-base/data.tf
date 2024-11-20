data "aws_iam_policy" "AWSResourceExplorerReadOnlyAccess" {
  name = "AWSResourceExplorerReadOnlyAccess"
}

data "aws_iam_policy" "ReadOnlyAccess" {
  name = "ReadOnlyAccess"
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}