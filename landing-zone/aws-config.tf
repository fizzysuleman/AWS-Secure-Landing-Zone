# # ---------------------------------------------------------
# # AWS Config S3 bucket
# # ---------------------------------------------------------

# resource "aws_s3_bucket" "config_logs" {
#   bucket        = "landing-zone-config-logs-faizal"
#   force_destroy = false

#   tags = {
#     Name      = "Landing Zone AWS Config Logs"
#     ManagedBy = "Terraform"
#     Project   = "Secure AWS Landing Zone"
#   }
# }


# # ---------------------------------------------------------
# # AWS Config bucket versioning
# # ---------------------------------------------------------

# resource "aws_s3_bucket_versioning" "config_logs" {
#   bucket = aws_s3_bucket.config_logs.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }


# # ---------------------------------------------------------
# # AWS Config bucket encryption
# # ---------------------------------------------------------

# resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
#   bucket = aws_s3_bucket.config_logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }


# # ---------------------------------------------------------
# # Block public access to AWS Config bucket
# # ---------------------------------------------------------

# resource "aws_s3_bucket_public_access_block" "config_logs" {
#   bucket = aws_s3_bucket.config_logs.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }


# # ---------------------------------------------------------
# # AWS Config trust policy
# #
# # Allows the AWS Config service to assume this IAM role.
# # ---------------------------------------------------------

# data "aws_iam_policy_document" "config_trust_policy" {
#   statement {
#     sid    = "AllowAWSConfigToAssumeRole"
#     effect = "Allow"

#     actions = [
#       "sts:AssumeRole"
#     ]

#     principals {
#       type = "Service"

#       identifiers = [
#         "config.amazonaws.com"
#       ]
#     }
#   }
# }


# # ---------------------------------------------------------
# # AWS Config IAM role
# # ---------------------------------------------------------

# resource "aws_iam_role" "config" {
#   name        = "aws-config-role"
#   description = "Allows AWS Config to inspect resource configurations."

#   assume_role_policy = data.aws_iam_policy_document.config_trust_policy.json

#   tags = {
#     Name      = "AWS Config Role"
#     ManagedBy = "Terraform"
#     Project   = "Secure AWS Landing Zone"
#   }
# }


# # ---------------------------------------------------------
# # Attach AWS-managed Config permissions
# # ---------------------------------------------------------

# resource "aws_iam_role_policy_attachment" "config" {
#   role       = aws_iam_role.config.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
# }


# # ---------------------------------------------------------
# # AWS Config bucket policy
# #
# # Allows AWS Config to inspect the bucket and deliver
# # configuration history and snapshots.
# # ---------------------------------------------------------

# data "aws_iam_policy_document" "config_bucket_policy" {
#   statement {
#     sid    = "AWSConfigBucketPermissionsCheck"
#     effect = "Allow"

#     principals {
#       type = "Service"

#       identifiers = [
#         "config.amazonaws.com"
#       ]
#     }

#     actions = [
#       "s3:GetBucketAcl",
#       "s3:ListBucket"
#     ]

#     resources = [
#       aws_s3_bucket.config_logs.arn
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceAccount"

#       values = [
#         data.aws_caller_identity.current.account_id
#       ]
#     }
#   }

#   statement {
#     sid    = "AWSConfigBucketDelivery"
#     effect = "Allow"

#     principals {
#       type = "Service"

#       identifiers = [
#         "config.amazonaws.com"
#       ]
#     }

#     actions = [
#       "s3:PutObject"
#     ]

#     resources = [
#       "${aws_s3_bucket.config_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "s3:x-amz-acl"

#       values = [
#         "bucket-owner-full-control"
#       ]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceAccount"

#       values = [
#         data.aws_caller_identity.current.account_id
#       ]
#     }
#   }
# }


# # ---------------------------------------------------------
# # Attach policy to AWS Config bucket
# # ---------------------------------------------------------

# resource "aws_s3_bucket_policy" "config_logs" {
#   bucket = aws_s3_bucket.config_logs.id
#   policy = data.aws_iam_policy_document.config_bucket_policy.json
# }


# # ---------------------------------------------------------
# # AWS Config configuration recorder
# #
# # Records all supported regional resources and supported
# # global resource types such as IAM.
# # ---------------------------------------------------------

# resource "aws_config_configuration_recorder" "landing_zone" {
#   name     = "landing-zone-config-recorder"
#   role_arn = aws_iam_role.config.arn

#   recording_group {
#     all_supported                 = true
#     include_global_resource_types = true
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.config
#   ]
# }


# # ---------------------------------------------------------
# # AWS Config delivery channel
# #
# # Delivers configuration snapshots and history to S3.
# # ---------------------------------------------------------

# resource "aws_config_delivery_channel" "landing_zone" {
#   name           = "landing-zone-config-delivery-channel"
#   s3_bucket_name = aws_s3_bucket.config_logs.bucket

#   snapshot_delivery_properties {
#     delivery_frequency = "TwentyFour_Hours"
#   }

#   depends_on = [
#     aws_s3_bucket_policy.config_logs
#   ]
# }


# # ---------------------------------------------------------
# # Enable AWS Config recorder
# # ---------------------------------------------------------

# resource "aws_config_configuration_recorder_status" "landing_zone" {
#   name       = aws_config_configuration_recorder.landing_zone.name
#   is_enabled = true

#   depends_on = [
#     aws_config_delivery_channel.landing_zone
#   ]
# }


# # ---------------------------------------------------------
# # Config rule: S3 bucket-level public access prohibited
# #
# # Checks whether each S3 bucket has secure bucket-level
# # Block Public Access settings.
# # ---------------------------------------------------------

# resource "aws_config_config_rule" "s3_bucket_public_access_prohibited" {
#   name        = "s3-bucket-level-public-access-prohibited"
#   description = "Checks whether S3 buckets prohibit public access at the bucket level."

#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
#   }

#   depends_on = [
#     aws_config_configuration_recorder_status.landing_zone
#   ]

#   tags = {
#     Name      = "S3 Bucket Public Access Prohibited"
#     ManagedBy = "Terraform"
#     Project   = "Secure AWS Landing Zone"
#   }
# }


# # ---------------------------------------------------------
# # Config rule: Restricted SSH
# #
# # Marks a security group NON_COMPLIANT when port 22 is open
# # to 0.0.0.0/0 or ::/0.
# # ---------------------------------------------------------

# resource "aws_config_config_rule" "restricted_ssh" {
#   name        = "restricted-ssh"
#   description = "Checks whether security groups restrict unrestricted inbound SSH access."

#   source {
#     owner             = "AWS"
#     source_identifier = "INCOMING_SSH_DISABLED"
#   }

#   depends_on = [
#     aws_config_configuration_recorder_status.landing_zone
#   ]

#   tags = {
#     Name      = "Restricted SSH"
#     ManagedBy = "Terraform"
#     Project   = "Secure AWS Landing Zone"
#   }
# }