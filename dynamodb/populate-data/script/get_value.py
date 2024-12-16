import json
import boto3
import os
from botocore.exceptions import ClientError

dynamodb = boto3.client("dynamodb")

TABLE_NAME = os.getenv("TABLE_NAME", "MyGT")


def get_item():
    keys_to_fetch = [
        {
            "PK": {"S": "Item1"},  # Primary Key for Item1
            "SK": {"S": "SortKey1"},  # Sort Key for Item1
        },
        {
            "PK": {"S": "Item2"},  # Primary Key for Item2
            "SK": {"S": "SortKey2"},  # Sort Key for Item2
        },
    ]

    # DynamoDB batch get operation requires keys to be grouped in batches of 100
    batch_size = 100
    num_batches = len(keys_to_fetch) // batch_size + (
        1 if len(keys_to_fetch) % batch_size > 0 else 0
    )
    # List to store the fetched items
    fetched_items = []

    for batch_num in range(num_batches):
        # Get the keys for the current batch (up to 100 keys per batch)
        batch_keys = keys_to_fetch[batch_num * batch_size : (batch_num + 1) * batch_size]
        # Prepare the batch get request
        request = {
            "RequestItems": {
                TABLE_NAME: {
                    "Keys": batch_keys,
                }
            }
        }

        try:
            # Perform the batch get operation
            response = dynamodb.batch_get_item(**request)
            print(json.dumps(response))
            # Fetch the items from the response
            items = response.get("Responses", {}).get(TABLE_NAME, [])
            fetched_items.extend(items)

            # Check if there are unprocessed keys (if the batch get was partial)
            unprocessed_keys = response.get("UnprocessedKeys", {}).get(TABLE_NAME, [])

            # If there are unprocessed keys, you may need to retry the batch
            while unprocessed_keys:
                print(f"Retrying unprocessed keys. Remaining: {len(unprocessed_keys)}")
                request["RequestItems"][TABLE_NAME]["Keys"] = unprocessed_keys
                response = dynamodb.batch_get_item(**request)
                unprocessed_keys = response.get("UnprocessedKeys", {}).get(TABLE_NAME, [])
                items = response.get("Responses", {}).get(TABLE_NAME, [])
                fetched_items.extend(items)

        except ClientError as e:
            # Handle any errors that occur during the batch get operation
            return {
                "statusCode": 500,
                "body": json.dumps(
                    f"Error fetching data: {e.response['Error']['Message']}"
                ),
            }

    # Return the fetched items
    return {
        "statusCode": 200,
        "body": json.dumps(f"{len(fetched_items)} items successfully fetched from DynamoDB", default=str),
    }
# get_item()

def import_item():
        items_to_insert = [
        {
            "PK": {"S": f"Item{i}"},  
            "SK": {"S": f"SortKey{i}"}, 
            "GSI1PK": {"S": f"Category200"}, 
            "GSI1SK": {"S": f"AppItem{i}"}, 
            "Name": {"S": f"AppItem {i} Name"}, 
            "Description": {"S": f"AppItem {i} Description"},  
        }
        for i in range(1, 201)  # Loop to create 200 items
    ]
        print(items_to_insert)

import_item()