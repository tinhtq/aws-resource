import boto3

dynamodb_client = boto3.client('dynamodb')

# Get the stream ARN from your table
table_name = "MyGT"
response = dynamodb_client.describe_table(TableName=table_name)
stream_arn = response['Table']['LatestStreamArn']

print(stream_arn)
# Get the shard iterator
streams_client = boto3.client('dynamodbstreams')
stream_response = streams_client.describe_stream(StreamArn=stream_arn)
shard_id = stream_response['StreamDescription']['Shards'][0]['ShardId']

shard_iterator_response = streams_client.get_shard_iterator(
    StreamArn=stream_arn,
    ShardId=shard_id,
    ShardIteratorType='TRIM_HORIZON'
)

shard_iterator = shard_iterator_response['ShardIterator']
while True:
    records_response = streams_client.get_records(ShardIterator=shard_iterator)
    for record in records_response['Records']:
        print(record)

    # Update shard iterator for the next loop
    shard_iterator = records_response['NextShardIterator']
