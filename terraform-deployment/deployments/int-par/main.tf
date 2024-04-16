provider "aws" {
  region = var.region
}

module "network" {
  source = "../network"

  region               = var.region
}

module "environment" {
  source = "../../environment"

  region               = var.region
  code-bucket-name     = var.code-bucket-name
  data-bucket-name     = var.data-bucket-name
  zip_file_path        = var.zip_file_path
  hdb-path             = var.hdb-path
  kms-key-id           = var.kms-key-id
  environment-name     = var.environment-name
  database-name        = var.database-name
  scaling-group-name   = var.scaling-group-name
  volume-name          = var.volume-name
  dataview-name        = var.dataview-name
  policy-name          = var.policy-name
  role-name            = var.role-name
  kx-user              = var.kx-user
  az-ids               = module.network.az-ids
}

module "clusters" {
  source = "../../clusters"

  init-script          = var.init-script
  create-clusters      = var.create-clusters
  rdb-count            = var.rdb-count
  hdb-count            = var.hdb-count
  discovery-count      = var.discovery-count
  gateway-count        = var.gateway-count
  feed-count           = var.feed-count
  environment-id       = module.environment.environment-id
  s3-code-object       = module.environment.s3-code-object
  database-name        = module.environment.database-name
  s3-bucket-id         = module.environment.s3-bucket-id
  s3-bucket-key        = module.environment.s3-bucket-key
  environment-resource = module.environment.environment-resource
  create-changeset     = module.environment.create-changeset
  execution-role       = module.environment.execution-role
  vpc-id               = module.network.vpc-id
  subnet-ids           = module.network.subnet-ids
  security-group-id    = module.network.security-group-id
  scaling-group        = module.environment.kdb-scaling-group
  volume-name          = var.volume-name
  dataview-name        = var.dataview-name 
}

module "network" {
  source = "../../network"

  region               = var.region
}

module "lambda" {
  source = "../../lambda"

  lambda-name          = var.lambda-name
  sfn-machine-name     = var.sfn-machine-name
  region               = var.region
  environment-id       = module.environment.environment-id
  account_id           = module.environment.account_id
  s3-bucket-id         = module.environment.s3-bucket-id
  s3-data-bucket-id    = module.environment.s3-data-bucket-id
  rdbCntr_mod          = var.rdbCntr_modulo
  send-sns-alert       = var.send-sns-alert
  alert-smpt-target    = var.alert-smpt-target
}

module "metricfilter" {
  source = "../../metricfilter"

  environment-id        = module.environment.environment-id
  sfn_state_machine_arn = module.lambda.sfn_state_machine_arn
  eventBridge_role_arn  = module.lambda.eventBridge_role_arn
  create-mfilters       = var.create-mfilters
  wdb_log_groups        = var.wdb_log_groups
}