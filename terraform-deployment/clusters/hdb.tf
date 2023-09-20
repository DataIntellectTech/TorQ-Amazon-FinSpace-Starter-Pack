resource "aws_finspace_kx_cluster" "hdb-cluster" {
  name                  = "hdb-cluster-${count.index+1}"
  environment_id        = var.environment-id
  type                  = "HDB"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = var.availability-zone
  initialization_script = var.init-script
  execution_role        = var.execution-role

  count = var.create-clusters == 1 ? var.hdb-count : 0

  depends_on = [
    var.s3-code-object, 
    var.create-changeset, 
    aws_finspace_kx_cluster.discovery-cluster,
    var.environment-resource
  ]
  
  command_line_arguments = {
    "procname"   = "hdb${count.index+1}"
    "proctype"   = "hdb"
    "noredirect" = "true"
  }
  
  capacity_configuration {
    node_type  = "kx.s.large"
    node_count = 1
  }

  code {
    s3_bucket = var.s3-bucket-id
    s3_key    = var.s3-bucket-key
  }

  vpc_configuration {
    vpc_id             = var.vpc-id
    security_group_ids = var.security-groups
    subnet_ids         = var.subnets
    ip_address_type    = "IP_V4"
  }

  database {
    database_name = var.database-name
  }

  lifecycle {
    ignore_changes = [database]
  }
}
