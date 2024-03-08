region            = "us-west-2"                              # region for kdb environment
kms-key-id        = "f0423ed6-d25f-4b1f-9398-d21a5f41d4ec"      # key id for kms key (create kms key first)

# file paths
zip_file_path     = "code.zip"        # path to zipped code
hdb-path          = "hdb"             # path to hdb to migrate

# unique names for aws/finspace resources
code-bucket-name  = "finspace-code-bucket"                 
data-bucket-name  = "finspace-data-bucket"                 
environment-name  = "env-test"                                
policy-name       = "finspace-policy"
role-name         = "finspace-role"
kx-user           = "finspace-user"

# lambda configs
lambda-name       = "finspace-lambda-scaling"
sfn-machine-name  = "finspace-scaler-state-machine"
rdbCntr_modulo    = 3
send-sns-alert    = false                                      # true=create email subscription. false=no email subscription
alert-smpt-target = "your.name@dataintellect.com"              # email address to send sns alerts to if send-alert flag is set to 'true'

# metricfilter configs
create-mfilters = false                                        # set to 'true' and rerun 'terraform apply' once wdb clusters have been created in your kxenvironment
wdb_log_groups = ["wdb1","wdb2"]                               # configure log groups with prefix "wdb" here eg. ["wdb1","wdb2"]

# database name
database-name     = "finspace-database"                        # database name should match name specified in env.q 
init-script       = "TorQ-Amazon-FinSpace-Starter-Pack/env.q"  # path to init script inside zipped folder

# cluster count
create-clusters   = 0                                        # 1=create no. of clusters specified below, 0=no clusters

rdb-count         = 0
hdb-count         = 0
gateway-count     = 0
feed-count        = 0
discovery-count   = 0