output "vpc_id" {
  value = data.aws_vpc.Default_vpc.id
}

output "subnet_id" {
  value = data.aws_subnet.default_subnet[*].id
}

output "defvpc_cidr" {
  value = data.aws_vpc.Default_vpc.cidr_block
}