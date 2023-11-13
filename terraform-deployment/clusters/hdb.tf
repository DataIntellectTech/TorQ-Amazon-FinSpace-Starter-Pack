resource "aws_finspace_kx_cluster" "hdb-cluster" {
  name                  = "hdb"
  environment_id        = var.environment-id
  type                  = "HDB"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = data.aws_subnet.subnet-0.availability_zone_id
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
    "s" = "2"
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

//  cache_storage_configurations {
//    type = "CACHE_1000"
//    size = 1200
//  }

  database {
    database_name = var.database-name
//   cache_configurations {
//   cache_type = "CACHE_1000"
//     db_paths   = ["/2015.01.15/","/2015.01.16/","/2015.01.17/","/2015.01.18/","/2015.01.19/","/2015.01.20/"]
//  }
  }

  lifecycle {
    ignore_changes = [database]
  }
}
