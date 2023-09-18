variable "availability-zone" {
  description = "default az for clusters"
  type        = string
}

variable "vpc-id" {
  description = "defailt vpc for clusters"
  type        = string
}

variable "subnets" {
  description = "subnet for cluster"
  type        = list(string)
}

variable "security-groups" {
  description = "security groups applied to cluster"
  type        = list(string)
}

variable "init-script" {
  description = "script to run on cluster startup"
  type        = string
}

variable "environment-id" {
 description = "finspace environment id"
}

variable "s3-code-object" {
 description = "s3 code object"
}

variable "database-name" {
 description = "name for finspace database"
}

variable "s3-bucket-id" {
 description = "id for code bucket"
}

variable "s3-bucket-key" {
 description = "key for code bucket object"
}

variable "environment-resource" {
  description = "finspace-environment"
}

variable "create-changeset" {
 description = "initial changeset"
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

variable "execution-role" {
  description = "role to apply to clusters"
  type        = string
}
