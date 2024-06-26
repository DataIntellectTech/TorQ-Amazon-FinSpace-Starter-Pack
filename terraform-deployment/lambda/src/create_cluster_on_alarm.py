import json
import boto3
#import botocore
import logging
import time
import sys
from env import *

logger = logging.getLogger()
logger.setLevel(logging.INFO)

defaultSession = boto3.Session()
client = defaultSession.client('finspace')

# if relying on "event", we need to ensure event is of a specific format
def lambda_handler(event, context):

    def filterByClusterPrefix(clusterSummaries, cluster_prefix):
        ret = [clusterSummary for clusterSummary in clusterSummaries if cluster_prefix in clusterSummary["clusterName"]]
        return ret
        
    eventKeys = event.keys()
    if "cluster_prefix" not in eventKeys or "clusterType" not in eventKeys:
        logging.error("event payload is not correct. Excpected \'cluster_prefix\' and \'clusterType\' within event keys")
        raise ValueError("event payload is not correct. Excpected \'cluster_prefix\' and \'clusterType\' within event keys")

    ## assume that if multiple RDBs, list_kx_clusters lists clusters by LIFO according to creationTimestamp
    cluster_name = cluster_prefix = event["cluster_prefix"]
    try:
        resp = client.list_kx_clusters(environmentId=envId, clusterType=event["clusterType"])
        filteredSummaries = filterByClusterPrefix(resp['kxClusterSummaries'], cluster_prefix)
        filteredSummaries.sort(key=lambda x: x['createdTimestamp'])
        cluster_name = filteredSummaries[-1]['clusterName']
    except Exception as err:
        logger.error(sys.exc_info())
        pass
        
    clusterInfo = client.get_kx_cluster(environmentId=envId, clusterName=cluster_name)
        
    cntr = cluster_name.replace(cluster_prefix,'')
    cntr = 1 if not cntr else int(cntr)
    cntr = (cntr%rdbCntr_modulo)+1
    newClusterId = f"{cluster_prefix}{cntr}"
    
    commandLineArgs = []
    for k in clusterInfo['commandLineArguments']:
        if k['key'] == 'procname':
            commandLineArgs.append({'key':'procname','value':newClusterId})
            commandLineArgs.append({'key':'replaceProc','value':k['value']})
            commandLineArgs.append({'key':'replaceCluster','value':cluster_name})
        elif k['key'] == 'replaceCluster' or k['key'] == 'replaceProc':
            pass
        else:
            commandLineArgs.append(k)
    logger.info("new command line args: %s" % commandLineArgs)
    
    clusterArgs = {
        'environmentId': envId,
        'clusterName': newClusterId,
        'clusterType': event["clusterType"],
        'clusterDescription': f"cluster for process {newClusterId}",
        'releaseLabel': clusterInfo['releaseLabel'],
        'vpcConfiguration': clusterInfo['vpcConfiguration'],
        'initializationScript' : clusterInfo['initializationScript'],
        'commandLineArguments' : commandLineArgs,
        'code': clusterInfo['code'],
        'executionRole': clusterInfo['executionRole'],
        'azMode' : clusterInfo['azMode'],
        'availabilityZoneId' :clusterInfo['availabilityZoneId']
    }

    # use capacityConfiguration if dedicated, scalingGroupConfiguration if on scaling group
    if 'capacityConfiguration' in clusterInfo:
        clusterArgs['capacityConfiguration'] = clusterInfo['capacityConfiguration']
    elif 'scalingGroupConfiguration' in clusterInfo:
        clusterArgs['scalingGroupConfiguration'] =  clusterInfo['scalingGroupConfiguration']        

    if 'savedownStorageConfiguration' in clusterInfo:
        clusterArgs['savedownStorageConfiguration'] = clusterInfo['savedownStorageConfiguration']

    if 'cacheStorageConfigurations' in clusterInfo:
        clusterArgs['cacheStorageConfigurations'] = clusterInfo['cacheStorageConfigurations']

    # handle databases
    if 'databases' in clusterInfo:
        databaseInfo = clusterInfo['databases'][0].copy()

        if 'changesetId' in databaseInfo and use_latest_changeset:
            latestChangeset = client.list_kx_changesets(environmentId=envId, databaseName=databaseInfo['databaseName'], maxResults=1)
            databaseInfo['changesetId'] = latestChangeset['kxChangesets'][0]['changesetId']

        if 'dataviewConfiguration' in databaseInfo:
            databaseInfo = {
                'databaseName': databaseInfo['databaseName'],
                'dataviewName': databaseInfo['dataviewConfiguration']['dataviewName']
            }
        elif not databaseInfo.get('cacheConfigurations', None):
            databaseInfo = { 
                'databaseName':databaseInfo['databaseName'],
                'changesetId':databaseInfo['changesetId']
            }
        clusterArgs['databases'] = [databaseInfo]
    
    logger.info(clusterArgs)
    
    logging.info("BEGINNING CREATION")
    
    client.create_kx_cluster(**clusterArgs)

    logging.info("CREATION COMPLETE")
    
    return {
        'statusCode': 200
    }