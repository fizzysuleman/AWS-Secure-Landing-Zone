# ---------------------------------------------------------
# Latest Amazon Linux 2023 AMI
# ---------------------------------------------------------


variable "deploy_demo_ec2" {
  type    = bool
  default = false
}

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
    //preventing the creation of the public EC2 instance if deploy_demo_ec2 is set to false
    count = var.deploy_demo_ec2 ? 1 : 0
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"

    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.public.id]

    key_name = "landing-zone-key"

    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

    tags = {
        Name      = "Landing Zone Public EC2 Instance"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}

# ---------------------------------------------------------
# Private EC2 Instance
# ---------------------------------------------------------
resource "aws_instance" "private" {
    count = var.deploy_demo_ec2 ? 1 : 0
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"

    subnet_id = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.private.id]

    key_name = "landing-zone-key"
    associate_public_ip_address = false
    iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

    tags = {
        Name      = "Landing Zone Private EC2 Instance"
        ManagedBy = "Terraform"
        Project   = "Secure AWS Landing Zone"
    }
}


