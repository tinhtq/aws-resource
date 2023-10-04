def lambda_handler(event, context):
    print(event)
    return { 
        'message' : "ok"
    }
