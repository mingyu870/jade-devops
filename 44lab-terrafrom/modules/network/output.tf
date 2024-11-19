output "subnets" {
  value = {
    public  = aws_subnet.public_subnets
    private = aws_subnet.private_subnets
  }
}

output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnet" {
  #  k is az
  value = { for k, v in aws_subnet.public_subnets : k => {
    az_id = v.availability_zone_id
    az    = v.availability_zone
    id    = v.id
    arn   = v.arn
  } }
}

output "private_subnet" {
  #  k is az
  value = { for k, v in aws_subnet.private_subnets : k => {
    az_id = v.availability_zone_id
    az    = v.availability_zone
    id    = v.id
    arn   = v.arn
  } }
}
