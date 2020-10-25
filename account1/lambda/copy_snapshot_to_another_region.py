# copy_snapshot_to_another_region.py

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
        snapshot_id = event["snapshot_id"]
        logger.info("snapshot_id = {}".format(snapshot_id))
        source_region = event["source_region"]
        logger.info("source_region = {}".format(source_region))
        destination_region = event["destination_region"]
        logger.info("destination_region = {}".format(destination_region))

        # copy a snapshort to another region
        result = copy_snapshot_to_another_region(snapshot_id, source_region, destination_region)

        if result == 200:
            logger.info("... snapshot {} copied successfully from {} to {}.".format(snapshot_id, source_region, destination_region))
            return {
                'statusCode': 200,
                'body': json.dumps('copy_snapshot_to_another_region was successful!')
            }
        else:
            logger.error("*** Error in copy_snapshot_to_another_region: {}".format(result))
            return {
                'statusCode': result,
                'body': json.dumps('copy_snapshot_to_another_region was not successful!')
            }
    except ClientError as e:
        logger.error("*** Error in copy_snapshot_to_another_region: {}".format(e))
        return {
            'statusCode': 500,
            'body': json.dumps('copy_snapshot_to_another_region was not successful!')
        }


def copy_snapshot_to_another_region(snapshot_id, source_region, destination_region):
    logger.info("Copying snapshot {} from {} to {} ...".format(snapshot_id, source_region, destination_region))

    source_ec2 = boto3.client('ec2', region_name=source_region) 
    response = source_ec2.describe_snapshots(SnapshotIds=[snapshot_id])
    logger.info(response)
    volume_id=response["Snapshots"][0]['VolumeId']
    logger.info("volume_id={}".format(volume_id))

    # create snapshot in destination_region and use <volume_id> as name
    destination_ec2 = boto3.client('ec2', region_name=destination_region) # code works only if ec2 is running in destination_region!
    result = destination_ec2.copy_snapshot(
        Description="Copy of snapshot {} from {}".format(snapshot_id, source_region),
        SourceSnapshotId=snapshot_id,
        SourceRegion=source_region,
        DestinationRegion=destination_region,
        TagSpecifications=[
            {
                'ResourceType': 'snapshot',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': volume_id
                    },
                ]
            },
        ]
    )
    logger.info(result)   
    return result['ResponseMetadata']['HTTPStatusCode']
