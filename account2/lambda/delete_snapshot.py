# delete_snapshot.py

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
        snapshot_id = event["snapshot_id"]
        logger.info("snapshot_id = {}".format(snapshot_id))

        # delete the snapshot specified by "snapshot_id"
        delete_snapshot(snapshot_id, region)

        return {
            'statusCode': 200,
            'body': json.dumps('delete_snapshot was successful!')
        }
    except ClientError as e:
        logger.error("*** Error in delete_snapshot: {}".format(e))


def delete_snapshot(snapshot_id, region):
    logger.info("Deleting snapshot (snapshot_id={}) ...".format(snapshot_id))

    # delete snapshot
    ec2resource = boto3.resource('ec2', region_name=region)
    snapshot = ec2resource.Snapshot(snapshot_id)
    snapshot.delete()

    logger.info("... snapshot was deleted successfully (snapshot_id = {}).".format(snapshot_id))

    return snapshot_id
