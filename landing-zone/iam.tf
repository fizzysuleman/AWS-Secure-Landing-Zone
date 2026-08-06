# ---------------------------------------------------------
# Current AWS account information
# ---------------------------------------------------------

data "aws_caller_identity" "current" {}


# ---------------------------------------------------------
# IAM account password policy
# ---------------------------------------------------------

resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length        = 14
  require_symbols                = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 90
  password_reuse_prevention      = 24
}


# ---------------------------------------------------------
# Security read-only role trust policy
#
# Answers:
# "Who is allowed to assume this role?"
# ---------------------------------------------------------

data "aws_iam_policy_document" "security_read_only_trust_policy" {
  statement {
    sid    = "AllowAccountPrincipalsToAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "true"
      ]
    }
  }
}


# ---------------------------------------------------------
# Security read-only IAM role
# ---------------------------------------------------------

resource "aws_iam_role" "security_read_only" {
  name        = "security-read-only-role"
  description = "Provides read-only access for reviewing AWS resources and security configurations."

  assume_role_policy   = data.aws_iam_policy_document.security_read_only_trust_policy.json
  max_session_duration = 3600

  tags = {
    Name      = "Security Read-Only Role"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}


# ---------------------------------------------------------
# Attach AWS SecurityAudit managed policy to the role
#
# Answers:
# "What security information can the role inspect?"
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "security_audit" {
  role       = aws_iam_role.security_read_only.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}


# ---------------------------------------------------------
# Attach AWS ViewOnlyAccess managed policy to the role
#
# Answers:
# "What AWS resources can the role view?"
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "view_only_access" {
  role       = aws_iam_role.security_read_only.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}


# ---------------------------------------------------------
# Security auditors IAM group
#
# Users added to this group can receive permission
# to request the security read-only role.
# ---------------------------------------------------------

resource "aws_iam_group" "security_auditors" {
  name = "security-auditors"
}


# ---------------------------------------------------------
# Assume-role permissions policy
#
# Answers:
# "What role are group members allowed to request?"
# ---------------------------------------------------------

data "aws_iam_policy_document" "allow_assume_security_read_only" {
  statement {
    sid    = "AllowAssumeSecurityReadOnlyRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      aws_iam_role.security_read_only.arn
    ]
  }
}


# ---------------------------------------------------------
# Create the managed assume-role policy
# ---------------------------------------------------------

resource "aws_iam_policy" "allow_assume_security_read_only" {
  name        = "AllowAssumeSecurityReadOnlyRole"
  description = "Allows security auditors to assume the security read-only role."

  policy = data.aws_iam_policy_document.allow_assume_security_read_only.json

  tags = {
    Name      = "Allow Assume Security Read-Only Role"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}


# ---------------------------------------------------------
# Attach assume-role policy to security auditors group
# ---------------------------------------------------------

resource "aws_iam_group_policy_attachment" "security_auditors_assume_role" {
  group      = aws_iam_group.security_auditors.name
  policy_arn = aws_iam_policy.allow_assume_security_read_only.arn
}


# ---------------------------------------------------------
# Add existing test user to security auditors group
#
# Replace "iam-test-user" if your username is different.
# This does not create the user.
# ---------------------------------------------------------

resource "aws_iam_group_membership" "security_auditors" {
  name  = "security-auditors-membership"
  users = var.security_auditor_user_names
  group = aws_iam_group.security_auditors.name
}


# ---------------------------------------------------------
# IAM Access Analyzer
# ---------------------------------------------------------

resource "aws_accessanalyzer_analyzer" "account_analyzer" {
  analyzer_name = "landing-zone-account-analyzer"
  type          = "ACCOUNT"

  tags = {
    Name      = "Landing Zone Account Analyzer"
    ManagedBy = "Terraform"
    Project   = "Secure AWS Landing Zone"
  }
}
