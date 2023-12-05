region            = "us-east-2"                                 # region for kdb environment
kms-key-id        = "c8f9ea11-d45c-45d4-86fd-e8994e2ab6f0"      # key id for kms key (create kms key first)

# file paths
zip_file_path     = "../code.zip"                               # path to zipped code
init-script       = "TorQ-Amazon-FinSpace-Starter-Pack/env.q"          # initialization script
hdb-path          = "../TorQ-Amazon-FinSpace-Starter-Pack/hdb"        	# path to hdb to migrate 

# network details
availability-zone = "use2-az1"                                  # availability zone ID
vpc-id            = "vpc-2b89ff40"                              # vpc for cluster endpoints
subnets           = ["subnet-b70c92dc"]                         # subnet associated with above az
security-groups   = ["sg-c370258f"]                             # list of security groups attached to each cluster

# unique names for aws/finspace resources
code-bucket-name  = "finspace-code-bucket-ohio"               
data-bucket-name  = "finspace-data-bucket-ohio"                 
environment-name  = "ohio-env"                                
database-name     = "finspace-database"                            
policy-name       = "finspace-policy-ohio"
role-name         = "finspace-role-ohio"
kx-user           = "finspace-user-ohio"

# cluster count
create-clusters   = 1                                          # 1=create no. of clusters specified below, 0=no clusters

rdb-count         = 1
hdb-count         = 1
gateway-count     = 1
feed-count        = 1
discovery-count   = 1
