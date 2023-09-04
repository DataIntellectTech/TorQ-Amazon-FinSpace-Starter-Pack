resource "aws_finspace_kx_cluster" "discovery-cluster" {
  name                  = "discovery-cluster"
  environment_id        = var.environment-id
  type                  = "RDB"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = var.availability-zone
  initialization_script = var.init-script



  savedown_storage_configuration {
    type = "SDS01"
    size = 10
  }

  capacity_configuration {
    node_type  = "kx.s.large"
    node_count = 1
  }

  code {
    s3_bucket = var.s3-bucket
    s3_key    = var.s3-key
  }

  command_line_arguments =  {
    procname   = "discovery1"
    proctype   = "discovery"
    noredirect = "true"
  }

 vpc_configuration {
    vpc_id             = var.vpc
    security_group_ids = var.security-group
    subnet_ids         = var.subnet
    ip_address_type    = "IP_V4"
  }
}
