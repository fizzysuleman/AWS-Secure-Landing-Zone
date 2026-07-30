# ---------------------------------------------------------
# Latest Amazon Linux 2023 AMI
# ---------------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ---------------------------------------------------------
# Public EC2 Instance
# ---------------------------------------------------------
resource "aws_instance" "public" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"

    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.public.id]

    key_name = "landing-zone-key"

    associate_public_ip_address = true

    tags = {
        Name      = "Landing Zone Public EC2 Instance"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}
