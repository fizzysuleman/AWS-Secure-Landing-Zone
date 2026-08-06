output "public_ec2_ip" {
  description = "Public IP of the demo EC2 instance"
  value       = try(aws_instance.public[0].public_ip, null)
}

output "private_ec2_ip" {
  description = "Private IPv4 address of the private EC2 instance"
  value       = try(aws_instance.private[0].private_ip, null)
}