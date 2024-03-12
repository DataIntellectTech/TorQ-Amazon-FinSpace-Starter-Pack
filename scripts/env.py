# config
environmentId = "33c4rqbmsx7bjclrrwb2gc"
clusterDescription = ""

# database settings
#databaseName = "finspace-database"
#changesetId = "jMb5FJhQ8afvzdQFP0uGSw"
databaseName = "finspace-database-intpar"
changesetId = "PscZoUKsqvQXO2Lysyzmkg"

# node settings
nodeType = "kx.s.large"
nodeCount = 1

# availability mode - "SINGLE" or "MULTI"
azMode = "SINGLE" 
availabilityZoneId = "use1-az6"

# code settings
s3Bucket = "finspace-code-bucket-virginia"
s3Key =  "74c2784f7019a59b0a6fedb79f0f69716762c599.zip"
#s3Key = "code_rel.zip"
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

# network settings
vpcId = "vpc-0a5b1db302525d776"
subnetIds = ["subnet-00dbf269c0172ec77"] # can be a list
securityGroupIds = ["sg-09d7de163f7d0327b", "sg-029197cc9263e4f00"] # can be a list
ipAddressType = "IP_V4"

releaseLabel = "1.0"

region="us-east-1"
