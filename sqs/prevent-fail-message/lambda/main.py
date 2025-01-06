import json
import boto3
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def handler(event, context):
    # Get the DynamoDB table name from environment variables
    table_name = os.environ['DYNAMODB_TABLE']
    table = dynamodb.Table(table_name)

    for record in event['Records']:
        try:
            # Validate and decode the SQS message body
            if not record['body']:
                print(f"Empty message body for message ID: {record['messageId']}")
                continue

            try:
                message_body = json.loads(record['body'])
            except json.JSONDecodeError:
                message_body = record['body']

            # Process the message and prepare an item to store in DynamoDB
            item = {
                'ID': record['messageId'],
                'MessageBody': message_body
            }

            # Insert the item into the DynamoDB table
            table.put_item(Item=item)
            print(f"Successfully processed message ID: {record['messageId']}")
        
        except ClientError as e:
            print(f"Failed to process message ID: {record['messageId']} with error: {e.response['Error']['Message']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Messages processed successfully!')
    }
