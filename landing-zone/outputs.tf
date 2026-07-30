output "public_ec2_ip" {
  description = "Public IPv4 address of the public EC2 instance"
  value       = aws_instance.public.public_ip
}