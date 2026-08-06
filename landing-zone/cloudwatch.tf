# ---------------------------------------------------------
# CloudWatch Log Group for CloudTrail
# ---------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "/aws/cloudtrail/landing-zone"

  retention_in_days = 30

  tags = {
    Name      = "Landing Zone CloudTrail Logs"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}

# ---------------------------------------------------------
# Trust policy for CloudTrail
#
# Allows the CloudTrail service to assume this IAM role.
# ---------------------------------------------------------

data "aws_iam_policy_document" "cloudtrail_cloudwatch_trust" {
  statement {
    sid    = "AllowCloudTrailToAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }
}

# ---------------------------------------------------------
# IAM role used by CloudTrail to write to CloudWatch Logs
# ---------------------------------------------------------

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name               = "cloudtrail-cloudwatch-logs-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_trust.json

  tags = {
    Name      = "CloudTrail CloudWatch Logs Role"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}

# ---------------------------------------------------------
# CloudWatch Logs permissions for CloudTrail
#
# Allows CloudTrail to create log streams and publish events.
# ---------------------------------------------------------

data "aws_iam_policy_document" "cloudtrail_cloudwatch_permissions" {
  statement {
    sid    = "AllowCloudTrailToWriteLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:*"
    ]
  }
}

# ---------------------------------------------------------
# Managed IAM policy for CloudTrail CloudWatch access
# ---------------------------------------------------------

resource "aws_iam_policy" "cloudtrail_cloudwatch" {
  name        = "CloudTrailCloudWatchLogsPolicy"
  description = "Allows CloudTrail to publish events to the landing-zone CloudWatch log group."

  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_permissions.json

  tags = {
    Name      = "CloudTrail CloudWatch Logs Policy"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}


# ---------------------------------------------------------
# Attach CloudWatch permissions to the CloudTrail role
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch" {
  role       = aws_iam_role.cloudtrail_cloudwatch.name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch.arn
}