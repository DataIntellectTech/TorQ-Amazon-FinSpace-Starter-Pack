resource "aws_finspace_kx_cluster" "rdb-cluster" {
  name                  = "rdb"
  environment_id        = var.environment-id
  type                  = "RDB"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = data.aws_subnet.subnet-0.availability_zone_id
  initialization_script = var.init-script
  execution_role        = var.execution-role

  count = var.create-clusters == 1 ? var.rdb-count : 0

  depends_on = [
    var.s3-code-object, 
    aws_finspace_kx_cluster.discovery-cluster,
    var.environment-resource
  ]

  command_line_arguments = {
    "procname"   = "rdb${count.index+1}"
    "proctype"   = "rdb"
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
    security_group_ids = [var.security-group-id]
    subnet_ids         = [var.subnet-ids[0]]
    ip_address_type    = "IP_V4"
  }

  savedown_storage_configuration {
    type = "SDS01"
    size = 100
  }
}
