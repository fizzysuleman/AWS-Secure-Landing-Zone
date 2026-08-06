# ---------------------------------------------------------
# EC2 Trust Policy
# ---------------------------------------------------------

data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name = "landing-zone-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json

  tags = {
    Name      = "Landing Zone EC2 SSM Role"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }

}

# ---------------------------------------------------------
# Systems Manager Permissions
# ---------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ec2_ssm.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ---------------------------------------------------------
# EC2 Instance Profile
# ---------------------------------------------------------
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "landing-zone-ec2-ssm-profile"

  role = aws_iam_role.ec2_ssm.name
}


# ---------------------------------------------------------
# Security group for Systems Manager VPC endpoints
# ---------------------------------------------------------

resource "aws_security_group" "ssm_endpoints" {
  name        = "ssm-vpc-endpoints-security-group"
  description = "Allows private EC2 instances to reach Systems Manager endpoints over HTTPS"
  vpc_id      = aws_vpc.landing_zone.id

  ingress {
    description = "Allow HTTPS from private EC2 security group"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    security_groups = [
      aws_security_group.private.id
    ]
  }

  egress {
    description = "Allow endpoint response traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name      = "SSM VPC Endpoints Security Group"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}

# ---------------------------------------------------------
# Systems Manager interface VPC endpoints
# ---------------------------------------------------------

locals {
  ssm_endpoint_services = toset([
    "ssm",
    "ssmmessages",
    "ec2messages"
  ])
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = local.ssm_endpoint_services

  vpc_id            = aws_vpc.landing_zone.id
  vpc_endpoint_type = "Interface"

  service_name = "com.amazonaws.us-east-1.${each.value}"

  subnet_ids = [
    aws_subnet.private.id
  ]

  security_group_ids = [
    aws_security_group.ssm_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name      = "landing-zone-${each.value}-endpoint"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}