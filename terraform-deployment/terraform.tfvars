region            = "ca-central-1"                              # region for kdb environment
kms-key-id        = "8c77da67-0249-4c1c-b2bd-2c723bb6d1f4"      # key id for kms key (create kms key first)

# file paths
zip_file_path     = "../code.zip"                               # path to zipped code
hdb-path          = "../finTorq-App/hdb"                        # path to hdb to migrate 


# unique names for aws/finspace resources
code-bucket-name  = "finspace-code-bucket-cnda"               
data-bucket-name  = "finspace-data-bucket-cnda"                 
environment-name  = "canada-env"                                
policy-name       = "finspace-policy-cnda"
role-name         = "finspace-role-canada"
kx-user           = "finspace-user-canada"

# database name
database-name     = "finspace-database"                        # database name should match name specified in env.q 
init-script       = "finTorq-App/env.q"                        # path to init script inside zipped folder

# cluster count
create-clusters   = 1                                        # 1=create no. of clusters specified below, 0=no clusters

rdb-count         = 1
hdb-count         = 1
gateway-count     = 1
feed-count        = 1
discovery-count   = 1

