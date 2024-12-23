import json
import os
def lambda_handler(event, context):
    try:
        # Parse the incoming JSON body
        body = json.loads(event['body'])
        name = body.get("name", "World")  # Default to "World" if "name" is not provided
    except (TypeError, KeyError):
        # Handle cases where the body is invalid
        name = "World"
    app_name = os.environ("APP")
    # Create the response
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": f"Hello {name} from {app_name} "})
    }
    return response
