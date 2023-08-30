resource "aws_finspace_kx_cluster" "discovery-cluster" {
  name                  = "discovery-cluster"
  environment_id        = var.environment-id
  type                  = "RDB"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = "use2-az2"
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
    procname   = "discovery"
    proctype   = "discovery"
    noredirect = "true"
  }

  vpc_configuration {
    vpc_id             = "vpc-2b89ff40"
    security_group_ids = ["sg-c370258f"]
    subnet_ids         = ["subnet-0569bd78"]
    ip_address_type    = "IP_V4"
  }
}
