resource "aws_finspace_kx_cluster" "cluster" {
  name                  = "hdb-cluster"
  environment_id        = aws_finspace_kx_environment.environment.id
  type                  = "HDB"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = "use2-az2"
  initialization_script = "code.q"
  depends_on            = [aws_s3_object.code]

  capacity_configuration {
    node_type  = "kx.s.large"
    node_count = 1
  }

  code {
    s3_bucket = aws_s3_bucket.finspace-code-bucket.id
    s3_key    = aws_s3_object.code.key
  }

  vpc_configuration {
    vpc_id             = "vpc-2b89ff40"
    security_group_ids = ["sg-c370258f"]
    subnet_ids         = ["subnet-0569bd78"]
    ip_address_type    = "IP_V4"
  }
}

resource "aws_finspace_kx_cluster" "cluster2" {
  name                  = "rdb-cluster"
  environment_id        = aws_finspace_kx_environment.environment.id
  type                  = "RDB"
  release_label         = "1.0"
  az_mode               = "SINGLE"
  availability_zone_id  = "use2-az2"
  initialization_script = "code.q"
  depends_on            = [aws_s3_object.code]

  capacity_configuration {
    node_type  = "kx.s.large"
    node_count = 1
  }

  code {
    s3_bucket = aws_s3_bucket.finspace-code-bucket.id
    s3_key    = aws_s3_object.code.key
  }

  vpc_configuration {
    vpc_id             = "vpc-2b89ff40"
    security_group_ids = ["sg-c370258f"]
    subnet_ids         = ["subnet-0569bd78"]
    ip_address_type    = "IP_V4"
  }

  savedown_storage_configuration {
    type = "SDS01"
    size = 4000
  }
}
