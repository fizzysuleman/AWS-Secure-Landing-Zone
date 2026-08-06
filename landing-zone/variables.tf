variable "aws_region" {
  description = "AWS Region used for regional landing-zone resources."
  type        = string
  default     = "us-east-1"
}

variable "deploy_demo_ec2" {
  description = "Whether to deploy the optional public and private EC2 demonstration instances."
  type        = bool
  default     = false
}

variable "security_alert_email" {
  description = "Optional email address for the SNS security-alert subscription. Leave null to omit the subscription."
  type        = string
  default     = null
  nullable    = true
}

variable "security_auditor_user_names" {
  description = "Existing IAM user names to add to the security-auditors group."
  type        = set(string)
  default     = []
}
