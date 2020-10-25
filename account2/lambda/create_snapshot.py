# create_snapshot.py

from botocore.exceptions import ClientError
import boto3
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:  
        # log event and extract its parameters
        logger.info("event = {}".format(event))
        region = event["region"]
        logger.info("region = {}".format(region))
        volume_id = event["volume_id"]
        logger.info("volume_id = {}".format(volume_id))

        # create a snapshort for the given volume
        snapshot_id = create_snapshot(volume_id, region)

        return {
            'statusCode': 200,
            'snapshot_id': snapshot_id, 
            'body': json.dumps('create_snapshot for volume {} was successful!'.format(volume_id))
        }
    except ClientError as e:
        logger.error("*** Error in create_snapshot: {}".format(e))
        raise


def create_snapshot(volume_id, region):
    logger.info("Creating snapshot for volume {} ...".format(volume_id))

    # create snapshot
    ec2 = boto3.client('ec2', region_name=region)
    result = ec2.create_snapshot(VolumeId=volume_id, Description='Created by lambda "create_snapshot"')
    snapshot_id = result['SnapshotId']
    
    # add volume id as a name for the snapshot for easier identification
    ec2resource = boto3.resource('ec2', region_name=region)
    snapshot = ec2resource.Snapshot(snapshot_id)
    snapshot.create_tags(Tags=[{'Key': 'Name','Value': volume_id}])        

    logger.info("... snapshot was created successfully for volume_id={}, snapshot_id = {}.".format(volume_id, snapshot_id))

    return snapshot_id
    