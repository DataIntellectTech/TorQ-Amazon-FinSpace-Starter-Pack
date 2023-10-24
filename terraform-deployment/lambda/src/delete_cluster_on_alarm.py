import json
import boto3
#import botocore
import logging
import time

logger = logging.getLogger()
logger.setLevel(logging.INFO)

defaultSession = boto3.Session()
client = defaultSession.client('finspace')

def lambda_handler(event, context):
    clusterInfo = client.get_kx_cluster(environmentId="ytcy24hpfrehp22hder66x", clusterName="rdb")
    logger.info("former capacityConfig is %s" % clusterInfo['capacityConfiguration']) 
    
    capacityConfiguration = clusterInfo['capacityConfiguration']
    capacityConfiguration['nodeCount'] = 1+clusterInfo['capacityConfiguration']['nodeCount'] #increase the nodeCount by one
    
    logger.info("new capacityConfig is %s" % capacityConfiguration)
    
    #logger.info(clusterInfo['databases'])
    #logger.info(clusterInfo['code'])
    #logger.info(clusterInfo['commandLineArguments'])
    
    clusterArgs = {
        'environmentId': "ytcy24hpfrehp22hder66x",
        'clusterName': "rdb2",
        'clusterType': "RDB",
        'databases': clusterInfo['databases'],
        'clusterDescription': "new rdb cluster",
        'capacityConfiguration': capacityConfiguration,
        'releaseLabel': clusterInfo['releaseLabel'],
        'vpcConfiguration': clusterInfo['vpcConfiguration'],
        'initializationScript' : clusterInfo['initializationScript'],
        'commandLineArguments' : clusterInfo['commandLineArguments'],
        'code': clusterInfo['code'],
        'executionRole': clusterInfo['executionRole'],
        'azMode' : clusterInfo['azMode'],
        'availabilityZoneId' :clusterInfo['availabilityZoneId']
    }
    
    logger.info(clusterArgs)

    logger.info("BEGINNING DELETION")
    
    client.delete_kx_cluster(environmentId="ytcy24hpfrehp22hder66x", clusterName="rdb")
    
    logger.info("DELETION COMPLETE")
    
    #time.sleep(5)
    
    #logging.info("BEGINNING CREATION")
    
    #client.create_kx_cluster(**clusterArgs)

    #logging.info("CREATION COMPLETE")
    
    
    return {
        'statusCode': 200
    }
