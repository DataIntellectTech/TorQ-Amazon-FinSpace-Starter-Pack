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

variable "security-group-id" {
  description = "security group for cluster endpoint"
}

variable "subnet-ids" {
  description = "list of available subnets"
}

variable "vpc-id" {
  description = "finspace vpc id"
}

data "aws_subnet" "subnet-0" {
  id = var.subnet-ids[0]
}

output "subnet-0-az-id" {
  value = data.aws_subnet.subnet-0.availability_zone_id
}
