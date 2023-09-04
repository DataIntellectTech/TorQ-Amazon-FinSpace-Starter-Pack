variable "region" {
  description = "AWS region"
  type        = string
}

provider "aws" {
  region = var.region
}

variable "environment-id" {
 description = "finspace environment id"
 type        = string
}

variable "init-script" {
 description = "file to load at startup"
 type        = string
}

variable "s3-bucket" {
 description = "name of s3 code bucket"
 type        = string
}

variable "s3-key" {
 description = "path to code file within bucket"
 type        = string
}

variable "database-name" {
 description = "name of database"
 type        = string
}

variable "hdb-count" {
 description = "number of hdb clusters"
 type = number
}

variable "rdb-count" {
 description = "number of hdb clusters"
 type = number
}

variable "subnet" {
  description = "subnet for cluster"
  type        = list(string)
}

variable "vpc" {
  description = "vpc for clsuter"
  type        = string
}

variable "security-group" {
  description = "security group for cluster"
  type        = list(string)
}

variable "availability-zone" {
  description = "availability zone for clusters"
  type = string
}
