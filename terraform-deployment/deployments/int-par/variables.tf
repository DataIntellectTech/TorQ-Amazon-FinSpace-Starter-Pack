variable "region" {
  description = "AWS region"
  type        = string
}

variable "code-bucket-name" {
  description = "name of s3 bucket containing code"
  type        = string
}

variable "data-bucket-name" {
  description = "name of s3 bucket containing data"
  type = string
}

variable "zip_file_path" {
  description = "path to zip file in code bucket"
  type = string
}

variable "hdb-path" {
  description = "location of hdb to migrate"
  type = string
}

variable "kms-key-id" {
  description = "key id for kms key"
  type        = string
}

variable "environment-name" {
  description = "name of finspace environment"
  type        = string
}

variable "database-name" {
  description = "name of kdb database"
  type        = string
}

variable "scaling-group-name" {
  description = "name of kdb scaling group"
  type        = string
}

variable "volume-name" {
  description = "name of shared volume"
  type        = string
}

variable "dataview-name" {
  description = "name of finspace dataview"
  type        = string
}

variable "policy-name" {
  description = "name of policy attached to IAM role"
  type        = string
}

variable "role-name" {
  description = "name of IAM role"
  type        = string
}

variable "kx-user" {
  description = "name of finspace user"
  type        = string
}

variable "init-script" {
  description = "script to run on cluster startup"
  type        = string
}

variable "create-clusters" {
  description = "whether or not to create clusters"
}

variable "feed-count" {
  description = "no of feed clusters to create"
}

variable "rdb-count" {
  description = "no of rdb clusters to create"
}

variable "hdb-count" {
  description = "no of hdb clusters to create"
}

variable "gateway-count" {
  description = "no of gateway clusters to create"
}

variable "discovery-count" {
  description = "no of discovery clusters to create"
}

variable "lambda-name" {
  description = "import name of the function"
  type = string
}

variable "sfn-machine-name" {
  description = "import the name of your step function"
  type = string
}

variable "rdbCntr_modulo" {
  description = "maximum number of rdbs created by lambda"
}

variable "send-sns-alert" {
  description = "flag to send sns emails or not"
}

variable "alert-smpt-target" {
  description = "email address to send sns alerts to. only used if send-alert set to 'true'"
}

variable "create-mfilters" {
  description = "flag to create metric filters on wdb log groups"
}

variable "wdb_log_groups" {
  type = list
  description = "list of existing log group names like 'wdb*'"
}
