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
        kms_key_id = None
        try:
            kms_key_id = event["kms_key_id"]
            logger.info("kms_key_id = {}".format(kms_key_id))
        except:
            pass

        # copy a snapshort to another region
        copy_snapshot_id = copy_snapshot_to_another_region(snapshot_id, source_region, destination_region, kms_key_id)
        return {
            'statusCode': 200,
            'copy_snapshot_id': copy_snapshot_id,
            'body': json.dumps('copy_snapshot_to_another_region for snapshot {} was successful!'.format(snapshot_id))
        }
    except ClientError as e:
        logger.error("*** Error in copy_snapshot_to_another_region: {}".format(e))
        raise

def copy_snapshot_to_another_region(snapshot_id, source_region, destination_region, kms_key_id):
    logger.info("Copying snapshot {} from {} to {} ...".format(snapshot_id, source_region, destination_region))

    source_ec2 = boto3.client('ec2', region_name=source_region) 
    response = source_ec2.describe_snapshots(SnapshotIds=[snapshot_id])
    logger.info(response)
    volume_id=response["Snapshots"][0]['VolumeId']
    logger.info("volume_id={}".format(volume_id))

    # create snapshot in destination_region and use <volume_id> as name
    destination_ec2 = boto3.client('ec2', region_name=destination_region) # code works only if ec2 is running in destination_region!
    result = None
    if kms_key_id is None:
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
    else:
        result = destination_ec2.copy_snapshot(
            Encrypted=True,
            KmsKeyId=kms_key_id,
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
                        {
                            'Key': 'KmsKeyId',
                            'Value': kms_key_id
                        },
                    ]
                },
            ]
        )

    logger.info(result)   
    if result['ResponseMetadata']['HTTPStatusCode'] != 200:
        raise ClientError()
    copy_snapshot_id = result['SnapshotId']
    logger.info("... snapshot {} copied successfully from {} to {} with kms_key_id={}, copy_snapshot_id={}.".format(snapshot_id, source_region, destination_region, kms_key_id, copy_snapshot_id))
    return copy_snapshot_id
