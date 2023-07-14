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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "s3-code-policy" {
  statement {
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.finspace-code-bucket.arn}/*"
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
      values   = ["766012286003"]
    }
  }

  statement {
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.finspace-code-bucket.arn}"
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
      values   = ["766012286003"]
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
      values   = ["766012286003"]
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
      values   = ["766012286003"]
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
  bucket = var.code-bucket-name
  key = "${sha1(filebase64(var.zip_file_path))}.zip"
  source = var.zip_file_path
}

#resource "null_resource" "upload_hdb" {
#  provisioner "local-exec" {
#    command = "aws s3 cp --recursive hdb s3://finspace-data-bucket/hdb"
#  }
#}

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
      "${aws_finspace_kx_environment.environment.arn}/kxCluster/${aws_finspace_kx_cluster.cluster.name}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "finspace:GetKxConnectString"
    ]
    resources = [
      "${aws_finspace_kx_environment.environment.arn}/kxCluster/${aws_finspace_kx_cluster.cluster.name}"
    ]
  }
}

resource "aws_iam_policy" "finspace-policy" {
  name   = "finspace-policy"
  policy = data.aws_iam_policy_document.iam-policy.json
} 

resource "aws_iam_role" "finspace-test-role" {
  name = "finspace-user-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::766012286003:root",
        "Service": "finspace.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role      = aws_iam_role.finspace-test-role.name
  policy_arn = aws_iam_policy.finspace-policy.arn
}

resource "aws_finspace_kx_user" "finspace-user" {
  name           = "finspace-user-ohio"
  environment_id = aws_finspace_kx_environment.environment.id
  iam_role       = aws_iam_role.finspace-test-role.arn
}




