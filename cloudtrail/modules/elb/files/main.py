import time
import json
import boto3
import sys
import os
REGION = os.getenv("REGION")


def lambda_handler(event, context):
    # attach_tags(event['detail']['responseElements']['vpc']['vpcId'])
    print(event['detail'])
    if event['detail']['userIdentity']["type"] == "AssumedRole":
        principal = event['detail']['userIdentity']['principalId']
        username = principal.split(':')[1]
    elif event['detail']['userIdentity']["type"] == "IAMUser":
        username = event['detail']['userIdentity']['userName']
    time.sleep(300)
    eventName = event['detail']['eventName']
    resource = ""
    resourceId = ""
    if eventName.startswith('Create'):
        resource = event['detail']['eventName'][6:]
        resource = resource[0].lower() + resource[1:]
        resourceId = resource + "Name"
    else:
        return {
            'statusCode': 500,
            'body': json.dumps('Error in AutoTagger!!')
        }

    resource += 's'

    match eventName:
        case _:
            attach_tags(event['detail']['responseElements']['loadBalancers'][0][resourceId],
                        event['detail']['responseElements']['loadBalancers'][0], username)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from AutoTagger!!')
    }


def attach_tags(resource_id, responseElements, username):
    existing_tags = []
    tags = []
    tags.append({"Key": "user", "Value": username})

    if 'tagList' in responseElements:
        if 'items' in responseElements['tagList']:
            existing_tags = responseElements['tagList']['items']
            existing_tags = {i['key']: i['value'] for i in existing_tags}
            print(existing_tags)
            if 'Name' in existing_tags and existing_tags['Name'] != "":
                tags.append({"Key": "Name", "Value": existing_tags['Name']})
            elif 'name' in existing_tags and existing_tags['name'] != "":
                tags.append({"Key": "name", "Value": existing_tags['name']})
            else:
                tags.append({"Key": "Name", "Value": resource_id})
        else:
            tags.append({"Key": "Name", "Value": resource_id})
    else:
        tags.append({"Key": "Name", "Value": resource_id})

    elb = boto3.client('elb', region_name=REGION)
    elb.add_tags(LoadBalancerNames=[resource_id], Tags=tags)
