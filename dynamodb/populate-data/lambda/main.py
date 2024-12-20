import json
import boto3
import os
from botocore.exceptions import ClientError

dynamodb = boto3.client("dynamodb")

TABLE_NAME = os.getenv("TABLE_NAME", "MyGT")


def lambda_handler(event, context):
    # Generate 200 items to insert into DynamoDB (for example purposes)
    items_to_insert = [
        {
            "PK": {"S": f"Item{i}"},  # Primary Key (e.g., Item1, Item2, ..., Item200)
            "SK": {"S": f"SortKey{i}"},  # Sort Key
            "GSI1PK": {"S": f"Category{i}"},  # Global Secondary Index Partition Key
            "GSI1SK": {"S": f"Item{i}"},  # Global Secondary Index Sort Key
            "Name": {"S": f"Item {i} Name"},  # Additional attribute
            "Description": {"S": f"Item {i} Description"},  # Additional attribute
        }
        for i in range(1, 201)  # Loop to create 200 items
    ]

    # DynamoDB batch write operation requires items to be grouped in batches of 25
    batch_size = 25
    num_batches = len(items_to_insert) // batch_size + (
        1 if len(items_to_insert) % batch_size > 0 else 0
    )

    for batch_num in range(num_batches):
        # Get the items for the current batch (up to 25 items per batch)
        batch_items = items_to_insert[
            batch_num * batch_size : (batch_num + 1) * batch_size
        ]

        # Prepare the batch write request
        write_requests = [{"PutRequest": {"Item": item}} for item in batch_items]

        try:
            # Perform the batch write operation
            response = dynamodb.batch_write_item(
                RequestItems={TABLE_NAME: write_requests}
            )

            # Check if there are unprocessed items (if the batch write was partial)
            unprocessed_items = response.get("UnprocessedItems", {}).get(TABLE_NAME, [])

            # If there are unprocessed items, you may need to retry the batch
            while unprocessed_items:
                print(
                    f"Retrying unprocessed items. Remaining: {len(unprocessed_items)}"
                )
                response = dynamodb.batch_write_item(
                    RequestItems={
                        TABLE_NAME: [
                            {"PutRequest": {"Item": item}} for item in unprocessed_items
                        ]
                    }
                )
                unprocessed_items = response.get("UnprocessedItems", {}).get(
                    TABLE_NAME, []
                )

        except ClientError as e:
            # Handle any errors that occur during the batch write operation
            return {
                "statusCode": 500,
                "body": json.dumps(
                    f"Error inserting data: {e.response['Error']['Message']}"
                ),
            }

    # Return a success message after all batches are inserted
    return {
        "statusCode": 200,
        "body": json.dumps("200 items successfully inserted into DynamoDB"),
    }

lambda_handler("","")