import json
def lambda_handler(event, context):
    message = {
        'message': 'Hello World'
    }

    return {
    'statusCode': 200,
    'headers': {'Content-Type': 'application/json'},
    'body': json.dumps(message)
    }