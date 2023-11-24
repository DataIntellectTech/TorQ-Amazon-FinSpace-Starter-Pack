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
    cluster_name = "rdb"
    try:
        metrics0 = event['detail']['configuration']['metrics'][0]
        cluster_name = metrics0['metricStat']['metric']['dimensions']['KxClusterId']
    except:
        pass
        
    clusterInfo = client.get_kx_cluster(environmentId="ytcy24hpfrehp22hder66x", clusterName=cluster_name)
    
    logger.info("former capacityConfig is %s" % clusterInfo['capacityConfiguration']) 
    
    capacityConfiguration = clusterInfo['capacityConfiguration'].copy()
    capacityConfiguration['nodeCount'] = 1+clusterInfo['capacityConfiguration']['nodeCount'] #increase the nodeCount by one
    
    logger.info("new capacityConfig is %s" % capacityConfiguration)

    databaseInfo = [{
        'databaseName':clusterInfo['databases'][0]['databaseName'],
        'changesetId':clusterInfo['databases'][0]['changesetId']
    }]
    
    commandLineArgs = []
    for k in clusterInfo['commandLineArguments']:
        if k['key'] == 'procname':
            commandLineArgs.append({'key':'procname','value':f"{k['value']}1"})
        else:
            commandLineArgs.append(k)
    logger.info("new command line args: %s" % commandLineArgs)
    
    #logger.info(clusterInfo['databases'])
    #logger.info(clusterInfo['code'])
    #logger.info(clusterInfo['commandLineArguments'])
    
    clusterArgs = {
        'environmentId': "ytcy24hpfrehp22hder66x",
        'clusterName': "rdb2",
        'clusterType': "RDB",
        'databases': databaseInfo,
        'clusterDescription': "new rdb cluster",
        'capacityConfiguration': capacityConfiguration,
        'releaseLabel': clusterInfo['releaseLabel'],
        'vpcConfiguration': clusterInfo['vpcConfiguration'],
        'initializationScript' : clusterInfo['initializationScript'],
        'commandLineArguments' : commandLineArgs,
        'code': clusterInfo['code'],
        'executionRole': clusterInfo['executionRole'],
        'savedownStorageConfiguration': clusterInfo['savedownStorageConfiguration'],
        'azMode' : clusterInfo['azMode'],
        'availabilityZoneId' :clusterInfo['availabilityZoneId']
    }
    
    logger.info(clusterArgs)
    
    logging.info("BEGINNING CREATION")
    
    client.create_kx_cluster(**clusterArgs)

    logging.info("CREATION COMPLETE")
    
    time.sleep(5)

    logger.info("BEGINNING DELETION")
    
    client.delete_kx_cluster(environmentId="ytcy24hpfrehp22hder66x", clusterName="rdb")
    
    logger.info("DELETION COMPLETE")
    
    time.sleep(5)

    return {
        'statusCode': 200
    }
