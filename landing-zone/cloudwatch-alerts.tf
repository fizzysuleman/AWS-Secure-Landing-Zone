# ---------------------------------------------------------
# SNS topic for security alerts
# ---------------------------------------------------------

resource "aws_sns_topic" "security_alerts" {
  name = "landing-zone-security-alerts"

  tags = {
    Name      = "Landing Zone Security Alerts"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}


# ---------------------------------------------------------
# Email subscription
# ---------------------------------------------------------

resource "aws_sns_topic_subscription" "security_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "fizzysuleman@gmail.com"
}


# ---------------------------------------------------------
# Metric filter for CloudTrail tampering
#
# Matches attempts to stop logging or delete the trail.
# ---------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "cloudtrail_tampering" {
  name           = "cloudtrail-tampering-detected"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  pattern = "{ ($.eventSource = \"cloudtrail.amazonaws.com\") && (($.eventName = \"StopLogging\") || ($.eventName = \"DeleteTrail\")) }"

  metric_transformation {
    name      = "CloudTrailTamperingAttempts"
    namespace = "LandingZoneSecurity"
    value     = "1"
  }
}


# ---------------------------------------------------------
# Alarm when CloudTrail tampering is detected
# ---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cloudtrail_tampering" {
  alarm_name        = "cloudtrail-tampering-detected"
  alarm_description = "Triggers when CloudTrail logging is stopped or the trail is deleted."

  namespace   = "LandingZoneSecurity"
  metric_name = "CloudTrailTamperingAttempts"

  statistic = "Sum"
  period    = 300

  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 1

  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.security_alerts.arn
  ]

  tags = {
    Name      = "CloudTrail Tampering Alarm"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}