# geneal environment variables

region            = "us-east-2"
environment-id    = "wdcqz6fxmp7m5wx73o3nuk"
init-script       = "finTorq-App/env.q"
s3-bucket         = "finspace-code-bucket"
s3-key            = "code.zip"
database-name     = "test-database"

# networking settings
# subnet should match AZ

vpc               = "vpc-2b89ff40"
security-group   = ["sg-c370258f"]
subnet           = ["subnet-0569bd78"]
availability-zone = "use2-az2" 

# rdb/hdb counts
# leave these at 1

rdb-count      = 1
hdb-count      = 1
