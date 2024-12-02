import boto3
import os
import datetime
import json


def lambda_handler(event, context):
    client = boto3.client("events")
    event_bus_arn = os.environ("EVENT_BUS_ARN")
    response = client.put_events(
        Entries=[
            {
                "Time": datetime.datetime.now(),
                "Source": "Custom Lambda",
                "Resources": [
                    "Local",
                ],
                "DetailType": "Custom Event Demo",
                "Detail": json.dumps(event),
                "EventBusName": event_bus_arn,
                "TraceHeader": "demo",
            },
        ],
        EndpointId="string",
    )
    return response
