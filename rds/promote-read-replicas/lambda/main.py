import boto3
from psycopg2 import sql
import time
from datetime import datetime, timedelta
import json
import os
import uuid
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    primary_instance_id = os.environ("RDS_PRIMARY_ID")
    topic_arn = os.environ("TOPIC_ARN")
    db_subnet_group_name = os.environ("SUBNET_GROUP_NAME")

    # Initialize AWS clients
    rds = boto3.client('rds')
    sns = boto3.client('sns')

    # Check CPU utilization
    try:
        response = rds.describe_db_instances(DBInstanceIdentifier=primary_instance_id)

        logger.info("Promoting read replica...")
        read_replicas = response['DBInstances'][0]['ReadReplicaDBInstanceIdentifiers']
        replica_instance_id = read_replicas[0].split(":")[-1]

        rds.promote_read_replica(DBInstanceIdentifier=replica_instance_id)

        sns.publish(
            TopicArn=topic_arn,
            Subject="RDS Failover Notification",
            Message=f"Primary RDS instance {primary_instance_id} is unhealthy. Promoting the read replica."
        )
        logger.info("Notification sent.")

        time.sleep(600)

        # Create a new read replica
        source = rds.describe_db_instances(DBInstanceIdentifier=replica_instance_id)
        primary_instance_arn = source['DBInstances'][0]['DBInstanceArn']
        new_db_instance_name = f"read-replica-{uuid.uuid4()}"
        rds.create_db_instance_read_replica(
            DBInstanceIdentifier=new_db_instance_name,
            SourceDBInstanceIdentifier=primary_instance_arn,
            DBSubnetGroupName=db_subnet_group_name,
            MultiAZ=False,
            PubliclyAccessible=False,
            Tags=[{'Key': 'ReadreplicaNumber', 'Value': new_db_instance_name}]
        )
        logger.info("New read replica created.")

    except Exception as e:
        logger.error(f"Error in monitoring or failover logic: {e}")

    logger.info("RDS Instance health check complete.")
