import json
import boto3
import os

s3_bucket = os.environ["BUCKET_NAME"]

def lambda_handler(event, context):
    objectContent = event['getObjectContext'];
    # The object from S3 is retrieved by the Lambda function
    s3_url = event['userRequest']["url"]
    splitted_url = s3_url.split("/")

    s3_object = splitted_url[3].split("?")[0]
    s3_client = boto3.client('s3')
    # Get Object
    obj = s3_client.get_object(Bucket=s3_bucket, Key=s3_object)
    documents = json.loads(obj['Body'].read())
    for document in documents:
        document.pop('name', None)
        document.pop('email', None)
        document.pop('phone', None)
        document.pop('address', None)
    
    # Convert the document back to a JSON string
    modified_document = json.dumps(documents)
    response = s3_client.write_get_object_response(
        RequestRoute=objectContent["outputRoute"],
        RequestToken=objectContent['outputToken'],
        Body=modified_document.encode('utf-8')
    )
    # Return the modified object (to the S3 Object Lambda API)
    return response
