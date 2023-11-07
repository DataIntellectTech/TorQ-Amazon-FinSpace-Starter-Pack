region            = "us-west-2"                              # region for kdb environment
kms-key-id        = "f0423ed6-d25f-4b1f-9398-d21a5f41d4ec"      # key id for kms key (create kms key first)

# file paths
zip_file_path     = "../code.zip"                               # path to zipped code, containing finTorq-App and TorQ with updated database name in env.q
hdb-path          = "../finTorq-App/hdb"                        # path to hdb to migrate 

# network details
# availability_zone = "use1-az6"
# vpc-id            = "vpc-0a5b1db302525d776"
# subnets           = ["subnet-b70c92dc"]
# security-groups   = ["sg-c370258f","sg-0ae04fc92abb499ca"]


# unique names for aws/finspace resources
code-bucket-name  = "finspace-code-bucket"               
data-bucket-name  = "finspace-data-bucket"                 
environment-name  = "env-test"                                
policy-name       = "finspace-policy"
role-name         = "finspace-role"
kx-user           = "finspace-user"
lambda-name       = "boto3-rdb-scaling"

# database name
database-name     = "finspace-database"                        # database name should match name specified in env.q 
init-script       = "finTorq-App/env.q"                        # path to init script inside zipped folder

# cluster count
create-clusters   = 0                                        # 1=create no. of clusters specified below, 0=no clusters

rdb-count         = 0
hdb-count         = 0
gateway-count     = 0
feed-count        = 0
discovery-count   = 0
