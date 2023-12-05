# config
environmentId = "rtci3jl7pii6tyhp5d2shk"
clusterDescription = "fintorq testing"

# database settings
databaseName = "finTorq_hdb"
changesetId = "RMSiPOI0nu8U7aO1EjkOEA"

# node settings
nodeType = "kx.s.large"
nodeCount = 1

# availability mode - "SINGLE" or "MULTI"
azMode = "SINGLE" 
availabilityZoneId = "euw1-az1"

# code settings
s3Bucket = "fintorq-eu-west1-code"
s3Key = "code.zip"
initScript = "TorQ-Amazon-FinSpace-Starter-Pack/env.q"

executionRole = "arn:aws:iam::766012286003:role/finTorq_hdb_connect"

commandLineArguments = [
    {"key":"noredirect", "value":"true"}
    ]

savedownStorageConfiguration={
        'type': 'SDS01',
        'size': 50
    }

# network settings
vpcId = "vpc-079ebe5fbb9198243"
subnetIds = ["subnet-0a547926c2f5f6c8d"] # can be a list
securityGroupIds = ["sg-06148e5f102f9f1dc", "sg-042c39003af04b1ce"] # can be a list
ipAddressType = "IP_V4"

releaseLabel = "1.0"

region="eu-west-1"
