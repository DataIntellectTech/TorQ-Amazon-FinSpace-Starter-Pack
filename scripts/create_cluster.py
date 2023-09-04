import boto3
import botocore
from datetime import datetime
import argparse
import sys
import time

from env import *

# ---------- Code -----------------------

def lg(lvl, msg):
    print(datetime.now().strftime("%Y.%m.%dD%H:%M:%S.%f") + " | " + lvl + " | " + msg)

def lgi(msg):
    lg("INFO", msg)

def lge(msg):
    lg("ERROR", msg)


def check_status(client, clusterName, action, waitForCompletion=False):
    lgi("querying status of {}".format(clusterName))

    status = ""

    while status != "RUNNING":
        try:
            resp = client.get_kx_cluster(
                environmentId=environmentId,
                clusterName=clusterName
                )
        except botocore.exceptions.ClientError as e:
            if (action == 'destroy') and e.response['Error']['Code'] == 'ResourceNotFoundException':
                lgi("kx cluster {} was not found - it has been successfully destroyed".format(clusterName))
                return True
            else:
                lge("something went wrong - {}".format(e))
                return False

        if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
            lge("Status query for {} failed - {}".format(clusterName, resp))
            return False

        status = resp['status']
        if status == "FAILED_TO_CREATE":
            err = resp.get('errorInfo', None)
            lge("Failed to create {} - error was {}".format(clusterName, err))
            return False
        elif status == "RUNNING":
            lgi("Kx cluster {} is RUNNING".format(clusterName))
            return False

        lgi("Current status for {} - {}".format(clusterName, status))
        
        if waitForCompletion:
            lgi("Will try again in 30 seconds")
            time.sleep(30)
        else:
            return True



def create_cluster(client, clusterName, clusterType, **kwargs):

    databases = [
        {
            "databaseName": databaseName,
            "changesetId": changesetId
        }
    ]
    capacityConfiguration = {
        "nodeType": nodeType,
        "nodeCount": nodeCount
    }
    vpcConfiguration = {
        "vpcId": vpcId,
        "securityGroupIds": securityGroupIds,
        "subnetIds": subnetIds,
        "ipAddressType": ipAddressType
    }
    code = {
        "s3Bucket": s3Bucket,
        "s3Key": s3Key
    }

    cmdLine = commandLineArguments.copy()
    
    for k, v in kwargs.items():
        if v is not None:
            cmdLine.append({'key':k, 'value':v})

    clusterArgs = {
        'environmentId': environmentId,
        'clusterName': clusterName,
        'clusterType': clusterType,
        'clusterDescription': clusterDescription,
        'capacityConfiguration': capacityConfiguration,
        'releaseLabel': releaseLabel,
        'vpcConfiguration': vpcConfiguration,
        'initializationScript' : initScript,
        'commandLineArguments' : cmdLine,
        'code': code,
        'executionRole': executionRole,
        'azMode' : azMode,
        'availabilityZoneId' :availabilityZoneId
    }

    if clusterType in ['RDB', 'HDB']:
        clusterArgs['databases'] = databases 

    if clusterType == 'RDB':
        clusterArgs['savedownStorageConfiguration'] = savedownStorageConfiguration

    lgi("creating kx cluster {} of type {} with params {}".format(clusterName, clusterType, clusterArgs))

    resp = client.create_kx_cluster(**clusterArgs)

    check_status(client, clusterName, 'create', waitForCompletion=True)

    return resp


def delete_cluster(client, clusterName):
    lgi("deleting kx cluster {}".format(clusterName))

    resp = client.delete_kx_cluster(
        environmentId=environmentId,
        clusterName=clusterName
    )

    check_status(client, clusterName, 'destroy', waitForCompletion=True)

    return resp


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=['create', 'destroy', 'check_status'], help="create or destroy")
    parser.add_argument("--clusterName", required=True, help="Name to give the cluster")
    parser.add_argument("--clusterType", 
                        required=("create" in sys.argv), # only required if the action was create
                        choices=['HDB', 'RDB', 'GATEWAY'],
                        help="Name to give the cluster"
                        )
    
    parser.add_argument("--proctype", help="type of the torq proc")
    parser.add_argument("--procname", help="name of the torq proc")
    
    args = parser.parse_args()

    client = boto3.client('finspace')
    lgi("testing aws connection")
    resp = client.get_kx_environment(environmentId=environmentId)
    if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
        lge("Failed to get environment - {}".format(resp))
        exit(1)

    lgi("Successfully found KX environment - {}".format(resp['name']))
    
    if args.action == 'create':
        resp = create_cluster(client, args.clusterName, args.clusterType, proctype=args.proctype, procname=args.procname)
    elif args.action == 'destroy':
        resp = delete_cluster(client, args.clusterName)
    elif args.action == 'check_status':
        resp = check_status(client, args.clusterName, 'create', waitForCompletion=False)
        exit(0)

    if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
        lge("Action {} failed - {}".format(args.action, resp))
        exit(1)
    
