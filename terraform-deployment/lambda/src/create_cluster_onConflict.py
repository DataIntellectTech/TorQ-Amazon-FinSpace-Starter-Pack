import json
import boto3
#import botocore
import re
import logging
import time
import sys
from env import *

logger = logging.getLogger()
logger.setLevel(logging.INFO)

defaultSession = boto3.Session()
client = defaultSession.client('finspace')

def lambda_handler(event, context):
    logging.info(event)
    
    eventKeys = event.keys()
    #gaurd 1
    if 'Error' not in eventKeys or 'Cause' not in eventKeys :
        logging.error("event payload is not correct. Excpected \'Error\' and \'Cause\' within event keys")
        raise ValueError("event payload is not correct. Excpected \'Error\' and \'Cause\' within event keys")
        
    #gaurd 2
    if event['Error'] != "ConflictException":
        logging.error(f"expected errorType : ConflictException. Found : {event['Error']}")
        raise ValueError(f"expected errorType : ConflictException. Found :  {event['Error']}")

    logging.warn("Function will only handle cases where cluster_name has format [a-zA-Z]+[0-9]*")
    
    parseMessage = ""
    if isinstance(event['Cause'],str):
        parseMessage = json.loads(event['Cause'])['errorMessage']
    elif isinstance(event['Cause'],dict):
        parseMessage = event['Cause']['errorMessage']

    match = re.findall(r'Cluster already exists with alias: [a-zA-Z]+[0-9]*',parseMessage)
    if not match:
        logging.error("Expected message not in payload. Aborting")
        raise ValueError("Expected message not in payload")
    cluster_name = match[0].split(":")[-1].strip()
    logging.info(cluster_name)
    
    clusterInfo = client.get_kx_cluster(environmentId=envId, clusterName=cluster_name)
    
    match = re.findall(r'[0-9]+',cluster_name)
    newClusterId = cluster_name
    if not match:
        newClusterId = f'{cluster_name}2'
    else:
        repl = str((int(match[0])%rdbCntr_modulo)+1)
        newClusterId = re.sub(match[0],repl,cluster_name)
    
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
        'clusterType': clusterInfo["clusterType"],
        'clusterDescription': f"cluster for process {newClusterId}",
        'capacityConfiguration': clusterInfo['capacityConfiguration'],
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
        'statusCode':200
    }