import json
import boto3
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    s3 = boto3.client('s3')
    biling_bucket = event['Records'][0]['s3']['bucket']['name']
    csv_file = event['Records'][0]['s3']['object']['key']

    error_bucket = 'error-bucket-25-Aug'
    obj = s3.get_object(biling_bucket,csv_file)
    data = obj.get()['Body'].read()
    return {
        'statusCode': 200,
        'body': json.dumps('Hello Lambda')
    }