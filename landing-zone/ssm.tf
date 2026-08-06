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