#Output values are like the return values of a Terraform module
output "vpc_id" {
  value = aws_vpc.vpc.id
}
