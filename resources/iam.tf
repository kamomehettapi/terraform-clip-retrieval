#
# S3 bucket for cluster logging
#

data "aws_s3_bucket" "log_bucket" {
  bucket = var.s3_log_bucket_name
}

locals {
  prefix = "clip-retrieval"
}

resource "aws_iam_policy" "added_policy" {
  name        = "grant-specific-s3-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "grantS3Access",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::${data.aws_s3_bucket.log_bucket.id}/*",
                "arn:aws:s3:::${data.aws_s3_bucket.log_bucket.id}"
            ]
        }
    ]
}
EOF
}

data "aws_iam_role" "role_for_s3_access" {
  name = data.tfe_outputs.workspace.values.aws_cross_account_role_name
}

data "aws_iam_policy_document" "pass_role_for_s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [data.aws_iam_role.role_for_s3_access.arn]
  }
}

resource "aws_iam_policy" "pass_role_for_s3_access" {
  name   = "${local.prefix}-pass-role-for-s3-access"
  path   = "/"
  policy = data.aws_iam_policy_document.pass_role_for_s3_access.json
}

resource "aws_iam_role_policy_attachment" "cross_account" {
  policy_arn = aws_iam_policy.pass_role_for_s3_access.arn
  role       = data.aws_iam_role.role_for_s3_access.name
}

// add grant s3 access policy to role
resource "aws_iam_role_policy_attachment" "s3-policy-attach" {
  policy_arn = aws_iam_policy.added_policy.arn
  role       = data.aws_iam_role.role_for_s3_access.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.prefix}-instance-profile"
  role = data.aws_iam_role.role_for_s3_access.name
}

resource "time_sleep" "arn_creation" {
  depends_on      = [aws_iam_instance_profile.instance_profile]
  create_duration = "30s"
}

resource "databricks_instance_profile" "instance_profile" {
  depends_on           = [time_sleep.arn_creation]
  instance_profile_arn = aws_iam_instance_profile.instance_profile.arn
  skip_validation      = false
}
