data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

variable "region" {
  description = "AWS region"
  type        = string
}

provider "aws" {
  region = var.region
}

variable "code-bucket-name" {
  description = "name of s3 bucket containing code"
  type        = string
}

resource "aws_s3_bucket" "finspace-code-bucket" {
  bucket = var.code-bucket-name
}

resource "aws_s3_bucket_versioning" "versioning" {
bucket = aws_s3_bucket.finspace-code-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "code_bucket" {
  bucket = aws_s3_bucket.finspace-code-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

variable "data-bucket-name" {
  description = "name of s3 bucket containing data"
  type = string
}

resource "aws_s3_bucket" "finspace-data-bucket" {
  bucket = var.data-bucket-name
}

resource "aws_s3_bucket_public_access_block" "data_bucket" {
  bucket = aws_s3_bucket.finspace-data-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3-code-policy" {
  statement {
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.finspace-code-bucket.arn}/*"
    ]
    actions = [
      "s3:GetObject", 
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging"
    ]
    principals {
      type        = "Service"
      identifiers = ["finspace.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }

  statement {
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.finspace-code-bucket.arn}"
    ]
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:ListBucketVersions"
    ]
    principals {
      type        = "Service"
      identifiers = ["finspace.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }
}

data "aws_iam_policy_document" "s3-data-policy" {
  statement {
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.finspace-data-bucket.arn}/*"
    ]
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging"
    ]
    principals {
      type        = "Service"
      identifiers = ["finspace.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }

  statement {
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.finspace-data-bucket.arn}"
    ]
    actions = [
      "s3:ListBucket"
    ]
    principals {
      type        = "Service"
      identifiers = ["finspace.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "code-policy" {
  bucket = aws_s3_bucket.finspace-code-bucket.id
  policy = data.aws_iam_policy_document.s3-code-policy.json
}

resource "aws_s3_bucket_policy" "data-policy" {
  bucket = aws_s3_bucket.finspace-data-bucket.id
  policy = data.aws_iam_policy_document.s3-data-policy.json
}

variable "zip_file_path" {
  description = "path to zip file in code bucket"
  type = string
}

resource "aws_s3_object" "code" {
  depends_on = [aws_s3_bucket.finspace-code-bucket]
  bucket     = var.code-bucket-name
  key        = "${sha1(filebase64(var.zip_file_path))}.zip"
  source     = var.zip_file_path
}

variable "hdb-path" {
  description = "path to hdb to reload"
  type = string
}

resource "null_resource" "upload_hdb" {
  depends_on = [aws_s3_bucket.finspace-data-bucket]

  provisioner "local-exec" {
    command = "aws s3 cp --region ${var.region} --recursive ${var.hdb-path} s3://${var.data-bucket-name}/hdb"
  }
}

variable "kms-key-id" {
  description = "key id for kms key"
  type        = string 
}

data "aws_kms_key" "finspace-key" {
  key_id = var.kms-key-id
}

resource "aws_ec2_transit_gateway" "test" {
  description = "test"
}

variable "environment-name" {
  description = "name of finspace environment"
  type        = string
}

resource "aws_finspace_kx_environment" "environment" {
  name       = var.environment-name
  kms_key_id = data.aws_kms_key.finspace-key.arn

  transit_gateway_configuration {
   transit_gateway_id  = aws_ec2_transit_gateway.test.id
   routable_cidr_space = "100.64.0.0/26"
  }
}

variable "database-name" {
  description = "name of kdb database"
  type        = string
}

resource "aws_finspace_kx_database" "database" {
  depends_on     = [aws_finspace_kx_environment.environment]
  environment_id = aws_finspace_kx_environment.environment.id
  name           = var.database-name
}

data "aws_iam_policy_document" "iam-policy" {
  statement {
    effect  = "Allow"
    actions = [
      "finspace:ConnectKxCluster"
    ]
    resources = [
      "${aws_finspace_kx_environment.environment.arn}/kxCluster/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "finspace:GetKxConnectionString"
    ]
    resources = [
      "${aws_finspace_kx_environment.environment.arn}/kxCluster/*"
    ]
  }
}

variable "policy-name" {
  description = "name of policy attached to IAM role"
  type        = string
}

resource "aws_iam_policy" "finspace-policy" {
  name   = var.policy-name
  policy = data.aws_iam_policy_document.iam-policy.json
} 

variable "role-name" {
  description = "name of IAM role"
  type        = string
}

resource "aws_iam_role" "finspace-test-role" {
  name = var.role-name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "Service": "finspace.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.finspace-test-role.name
  policy_arn = aws_iam_policy.finspace-policy.arn
}

variable "kx-user" {
  description = "name of finspace user"
  type        = string
}

resource "aws_finspace_kx_user" "finspace-user" {
  depends_on     = [aws_finspace_kx_environment.environment]
  name           = var.kx-user
  environment_id = aws_finspace_kx_environment.environment.id
  iam_role       = aws_iam_role.finspace-test-role.arn
}

resource "null_resource" "create_changeset" {

  depends_on = [aws_finspace_kx_database.database]

  provisioner "local-exec" {
    command = <<-EOT
      aws finspace create-kx-changeset \
        --region ${var.region} \
        --client-token "$(date +%s)-$(openssl rand -hex 4)" \
        --environment-id "${aws_finspace_kx_environment.environment.id}" \
        --database-name "${var.database-name}" \
        --change-requests '[
          {
            "changeType": "PUT",
            "s3Path": "s3://${var.data-bucket-name}/hdb/",
            "dbPath": "/"
          }
        ]'
    EOT
  }
}

output "environment-id" {
  value = aws_finspace_kx_environment.environment.id
}

output "s3-code-object" {
  value = aws_s3_object.code
}

output "database-name" {
  value = aws_finspace_kx_database.database.name
}

output "s3-bucket-id" {
  value = aws_s3_bucket.finspace-code-bucket.id
}

output "s3-bucket-key" {
  value = aws_s3_object.code.key
}

output "environment-resource" {
  value = aws_finspace_kx_environment.environment
}

output "create-changeset" {
  value = null_resource.create_changeset
}

output "execution-role" {
  value = aws_iam_role.finspace-test-role.arn
}
