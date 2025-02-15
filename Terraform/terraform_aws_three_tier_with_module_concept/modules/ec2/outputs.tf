output "ec2_instance_id" {
    value = aws_instance.ec2[*].host_id
}
output "ec2_publicip" {
  value = aws_instance.ec2[*].public_ip
}