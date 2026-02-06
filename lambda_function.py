import boto3
import os

def lambda_handler(event, context):
    endpoint = os.environ.get('AWS_ENDPOINT', 'http://localhost.localstack.cloud:4566')
    ec2 = boto3.client('ec2', endpoint_url=endpoint)
    instance_id = os.environ.get('INSTANCE_ID')
    
    # On récupère le chemin de la requête (ex: /start, /stop, /status)
    path = event.get('path', '')
    
    if 'start' in path:
        ec2.start_instances(InstanceIds=[instance_id])
        msg = f"Instance {instance_id} démarrée"
    elif 'stop' in path:
        ec2.stop_instances(InstanceIds=[instance_id])
        msg = f"Instance {instance_id} arrêtée"
    else:
        status = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]['State']['Name']
        msg = f"Statut de l'instance {instance_id} : {status}"

    return {
        'statusCode': 200,
        'body': msg
    }
