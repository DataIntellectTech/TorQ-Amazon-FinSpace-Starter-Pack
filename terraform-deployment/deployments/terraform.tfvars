region            = "eu-west-2"                              # region for kdb environment
kms-key-id        = "ab073e5e-2e4a-43fc-9662-e70982f6bf0b"      # key id for kms key (create kms key first)

# file paths
zip_file_path     = "../../../code.zip"                       # path to zipped code, containing finTorq-App and TorQ with updated database name in env.q
hdb-path          = "../../hdb"                               # path to hdb to migrate 


# unique names for aws/finspace resources
code-bucket-name  = "finspace-code-bucket-london"               
data-bucket-name  = "finspace-data-bucket-london"                 
environment-name  = "env-test-london-005"                                
policy-name       = "finspace-policy-london"
role-name         = "finspace-role-london"
kx-user           = "finspace-user-london"
scaling-group-name = "finTorq-scaling-group"
volume-name       = "finTorq-shared"
dataview-name     = "finspace-dataview"

# database name
database-name     = "finspace-database"                          # database name should match name specified in env.q 
init-script       = "TorQ-Amazon-FinSpace-Starter-Pack/env.q"    # path to init script inside zipped folder

# cluster count
create-clusters   = 1                                        # 1=create no. of clusters specified below, 0=no clusters

rdb-count         = 0
hdb-count         = 0
gateway-count     = 0
feed-count        = 0
discovery-count   = 1
