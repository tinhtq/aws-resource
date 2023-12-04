import json
import boto3
import sys
import os
REGION=os.getenv("REGION")

def lambda_handler(event, context):
    #attach_tags(event['detail']['responseElements']['vpc']['vpcId'])
    print(event['detail'])
    if event['detail']['userIdentity']["type"] == "AssumedRole":
        principal = event['detail']['userIdentity']['principalId']
        username = principal.split(':')[1]
    elif event['detail']['userIdentity']["type"] == "IAMUser":
        username = event['detail']['userIdentity']['userName']
        
    eventName = event['detail']['eventName']
    resource = ""
    resourceId = ""
    if eventName.startswith('Create'):
        resource = event['detail']['eventName'][6:]
        resource = resource[0].lower() +resource[1:]
        resourceId = resource + "Id"
    else:
        return {
            'statusCode': 500,
            'body': json.dumps('Error in AutoTagger!!')
        }
    match eventName:
        case "CreateTags":
            print("Create Tags")
        case _:
            attach_tags(event['detail']['responseElements'][resourceId], event['detail']['responseElements'], username)
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
            if 'Name' in existing_tags and existing_tags['Name']!= "":
                tags.append({"Key": "Name", "Value": existing_tags['Name']})
            elif 'name' in existing_tags and existing_tags['name']!= "":
                tags.append({"Key": "name", "Value": existing_tags['name']})
            else:
                tags.append({"Key": "Name", "Value": resource_id})
        else:
            tags.append({"Key": "Name", "Value": resource_id})
    else:
        tags.append({"Key": "Name", "Value": resource_id})

    efs = boto3.client('efs', region_name=REGION)
    efs.create_tags(FileSystemId=resource_id, Tags=tags)