import boto3
from psycopg2 import sql
import time
from datetime import datetime, timedelta
import json
import os
import uuid

def lambda_handler(event, context):
    secret_name = os.environ("SECRET_NAME")
    primary_instance_id = os.environ("RDS_PRIMARY_ID")
    topic_arn = os.environ("TOPIC_ARN")
    db_subnet_group_name = os.environ("SUBNET_GROUP_NAME")

    secrets_manager = boto3.client('secretsmanager')
    res = secrets_manager.get_secret_value(SecretId=secret_name)
    secret_data = json.loads(res['SecretString'])
    db_user = secret_data['username']
    db_pass = secret_data['password']

    now = datetime.now()
    past = now - timedelta(minutes=60)

    # Initialize AWS clients
    rds = boto3.client('rds')
    cloudwatch = boto3.client('cloudwatch')
    sns = boto3.client('sns')

    try:
        # Get primary DB instance status
        response = rds.describe_db_instances(DBInstanceIdentifier=primary_instance_id)
        status = response['DBInstances'][0]['DBInstanceStatus']
        endpoint = response['DBInstances'][0]['Endpoint']['Address']
        port = response['DBInstances'][0]['Endpoint']['Port']

        conn = psycopg2.connect(
            host=endpoint,
            port=port,
            user=db_user,
            password=db_pass,
            dbname="postgres"  # Replace with your database name if different
        )
        if conn:
            print("Connection successful")
            err = 0
        else:
            print("Connection unsuccessful")
            err = 1

    except Exception as e:
        err = 1
        print(f"Unable to connect to the RDS instance: {e}")
        print(f"DB Status: {status}, Endpoint: {endpoint}")

    # Check CPU utilization
    try:
        cpu_response = cloudwatch.get_metric_statistics(
            Namespace='AWS/RDS',
            MetricName='CPUUtilization',
            Dimensions=[
                {'Name': 'DBInstanceIdentifier', 'Value': primary_instance_id},
            ],
            StartTime=past,
            EndTime=now,
            Period=86400,
            Statistics=['Average'],
            Unit='Percent'
        )

        high_cpu_count = 0
        for cpu in cpu_response['Datapoints']:
            if cpu['Average'] >= 80 and err == 1:
                high_cpu_count += 1
                time.sleep(40)
            else:
                high_cpu_count = 0
                break

        # Promote read replica if conditions met
        if high_cpu_count >= 5:
            print("Promoting read replica...")
            read_replicas = response['DBInstances'][0]['ReadReplicaDBInstanceIdentifiers']
            replica_instance_id = read_replicas[0].split(":")[-1]

            rds.promote_read_replica(DBInstanceIdentifier=replica_instance_id)

            sns.publish(
                TopicArn=topic_arn,
                Subject="RDS Failover Notification",
                Message=f"Primary RDS instance {primary_instance_id} is unhealthy. Promoting the read replica."
            )
            print("Notification sent.")

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
            print("New read replica created.")

    except Exception as e:
        print(f"Error in monitoring or failover logic: {e}")

    print("RDS Instance health check complete.")
