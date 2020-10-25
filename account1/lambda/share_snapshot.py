# share_snapshot.py

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
        owner_account_id = event["owner_account_id"]
        logger.info("owner_account_id = {}".format(owner_account_id))
        other_account_id = event["other_account_id"]
        logger.info("other_account_id = {}".format(other_account_id))

        # share a snapshot with another account
        share_snapshot(snapshot_id, region, owner_account_id, other_account_id)
        return {
            'statusCode': 200,
            'body': json.dumps('share_snapshot {} was successful!'.format(snapshot_id))
        }
    except ClientError as e:
        logger.error("*** Error in share_snapshot: {}".format(e))
        raise


def share_snapshot(snapshot_id, region, owner_account_id, other_account_id):
    logger.info("Share snapshot {} in region {} owned by {} with another account {} ...".format(snapshot_id, region, owner_account_id, other_account_id))

    # share snapshot with another account
    ec2resource = boto3.resource('ec2', region_name=region)
    snapshot = ec2resource.Snapshot(snapshot_id)
    result = snapshot.modify_attribute(
        Attribute='createVolumePermission',
        OperationType='add',
        UserIds=[owner_account_id], # this attribute is perhaps optional
        CreateVolumePermission={
            'Add': [{'UserId': other_account_id}]
        }
    )
    logger.info("result = {}".format(result))
    if result['ResponseMetadata']['HTTPStatusCode'] != 200:
        raise ClientError()

    logger.info("... snapshot {} in region {} owned by {} was successfully shared with another account {}.".format(snapshot_id, region, owner_account_id, other_account_id))
