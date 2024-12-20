import json
def lambda_handler(event, context):
    print(event)
    message = {
        'message': 'Hello World'
    }

    return {
    'statusCode': 200,
    'headers': {'Content-Type': 'application/json'},
    'body': json.dumps(message)
    }