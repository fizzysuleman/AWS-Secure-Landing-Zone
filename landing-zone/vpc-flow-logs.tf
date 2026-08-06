resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/landing-zone-flow-logs"
  retention_in_days = 14

  tags = {
    Name      = "Landing Zone VPC Flow Logs"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "vpc-flow-logs.amazonaws.com"
      ]
    }
  }

}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_trust.json

  tags = {
    Name      = "VPC Flow Logs Role"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "vpc_flow_logs" {
  name        = "VPCFlowLogsCloudWatchPolicy"
  description = "Allows VPC Flow Logs to publish network flow records to CloudWatch Logs."

  policy = data.aws_iam_policy_document.vpc_flow_logs_permissions.json

  tags = {
    Name      = "VPC Flow Logs CloudWatch Policy"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  role       = aws_iam_role.vpc_flow_logs.name
  policy_arn = aws_iam_policy.vpc_flow_logs.arn
}

resource "aws_flow_log" "landing_zone" {
  vpc_id = aws_vpc.landing_zone.id

  traffic_type = "ALL"

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn

  iam_role_arn = aws_iam_role.vpc_flow_logs.arn

  max_aggregation_interval = 60

  depends_on = [
    aws_iam_role_policy_attachment.vpc_flow_logs
  ]

  tags = {
    Name      = "Landing Zone VPC Flow Logs"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}
