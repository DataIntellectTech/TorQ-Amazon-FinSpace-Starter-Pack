# config
environmentId = "33c4rqbmsx7bjclrrwb2gc"
clusterDescription = ""
scalingGroupName = "finTorq-scaling-group"

# database settings
databaseName = "finspace-database"
changesetId = "cMcNaQzs7to6Ca7eozXUow"
#databaseName = "finspace-database-intpar"
#changesetId = "PscZoUKsqvQXO2Lysyzmkg"
dataviewName = "finTorq_dataview"
volumeName   = "finTorq-shared"

# node settings
nodeType = "kx.s.large"
nodeCount = 1
memoryReservation = 6

# availability mode - "SINGLE" or "MULTI"
azMode = "SINGLE" 
availabilityZoneId = "use1-az6"

# code settings
s3Bucket = "finspace-code-bucket-virginia"
#s3Key =  "3e0305668574b121d1432e6af1c1771aad614033.zip"
s3Key = "code_rel.zip"
initScript = "TorQ-Amazon-FinSpace-Starter-Pack/env.q"

executionRole = "arn:aws:iam::766012286003:role/finspace-role-virginia"


commandLineArguments = [
    {"key":"noredirect", "value":"true"},
    {"key":"jsonlogs", "value":"true"}
    ]

savedownStorageConfiguration={
        'type': 'SDS01',
        'size': 10
    }

# flag for HDB to use cache or not
useCache=False

cacheConfiguration=[{
    'cacheType':'CACHE_1000',
    'dbPaths':['/']
   }]

cacheStorageConfiguration=[{
    'type':'CACHE_1000',
    'size':1200
}]

## tickerplant log volume configs - should be a list of volume names
#tickerplantLogVolumes = ["test-tp-volume"]

# network settings
vpcId = "vpc-0a5b1db302525d776"
subnetIds = ["subnet-00dbf269c0172ec77"] # can be a list
securityGroupIds = ["sg-09d7de163f7d0327b", "sg-029197cc9263e4f00"] # can be a list
ipAddressType = "IP_V4"

releaseLabel = "1.0"

region="us-east-1"
