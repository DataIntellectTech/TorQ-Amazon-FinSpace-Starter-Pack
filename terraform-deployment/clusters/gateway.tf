 resource "aws_finspace_kx_cluster" "gateway-cluster" {
  name                  = "gateway1"
  environment_id        = var.environment-id
  type                  = "GP"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = var.scaling-group.availability_zone_id  #data.aws_subnet.subnet-0.availability_zone_id
  initialization_script = var.init-script
  execution_role        = var.execution-role

  count = var.create-clusters == 1 ? var.gateway-count : 0

  depends_on = [
    var.s3-code-object,
    var.environment-resource,
    var.environment-id,
    var.scaling-group,
    aws_finspace_kx_cluster.discovery-cluster
  ]

  command_line_arguments = {
    "procname"   = "gateway${count.index+1}"
    "proctype"   = "gateway"
    "noredirect" = "true"
    "jsonlogs"   = "true"
  }


  #capacity_configuration {
  #  node_type  = "kx.s.large"
  #  node_count = 1
  #}

  scaling_group_configuration {
    scaling_group_name = var.scaling-group.name
    memory_reservation = 6
    node_count         = 1
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

  #savedown_storage_configuration {
  #  type = "SDS01"
  #  size = 100
  #}

  savedown_storage_configuration {
    volume_name = var.volume-name
  }
}
