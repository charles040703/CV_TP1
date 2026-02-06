import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', endpoint_url=os.environ['AWS_ENDPOINT_URL'])
    
    # On récupère l'action (start/stop) depuis la requête (query string)
    action = event.get('queryStringParameters', {}).get('action', 'status')
    instance_id = event.get('queryStringParameters', {}).get('instance_id')
    
    if not instance_id:
        return {'statusCode': 400, 'body': 'Missing instance_id'}

    if action == 'start':
        ec2.start_instances(InstanceIds=[instance_id])
        message = f"Instance {instance_id} démarrée."
    elif action == 'stop':
        ec2.stop_instances(InstanceIds=[instance_id])
        message = f"Instance {instance_id} arrêtée."
    else:
        message = "Action inconnue. Utilisez action=start ou action=stop."

    return {
        'statusCode': 200,
        'body': message
    }
