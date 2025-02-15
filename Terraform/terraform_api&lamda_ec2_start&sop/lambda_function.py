import boto3
import logging
import os
import json

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Get environment variables (provided by Terraform)
REGION = os.getenv('REGION')
AMI_ID = os.getenv('AMI_ID')
INSTANCE_TYPE = os.getenv('INSTANCE_TYPE')
KEY_NAME = os.getenv('KEY_NAME')
SUBNET_ID = os.getenv('SUBNET_ID')
INSTANCE_TAG_NAME = os.getenv('INSTANCE_TAG_NAME')

# Validate required environment variables
if not all([REGION, AMI_ID, INSTANCE_TYPE, KEY_NAME, SUBNET_ID, INSTANCE_TAG_NAME]):
    raise ValueError("Missing required environment variables.")

# Initialize EC2 client
ec2 = boto3.client('ec2', region_name=REGION)

def get_instance_id():
    """
    Fetches the EC2 instance ID dynamically using the tag name.
    """
    try:
        response = ec2.describe_instances(
            Filters=[
                {'Name': 'tag:Name', 'Values': [INSTANCE_TAG_NAME]},
                {'Name': 'instance-state-name', 'Values': ['running', 'stopped']}
            ]
        )
        instances = response.get('Reservations', [])
        if instances:
            return instances[0]['Instances'][0]['InstanceId']
        return None
    except Exception as e:
        logger.error(f"Error fetching instance ID: {str(e)}")
        return None

def lambda_handler(event, context):
    """
    Handles API Gateway POST requests to start or stop an EC2 instance.
    """
    try:
        # Parse request body (Handle API Gateway string encoding)
        body = json.loads(event.get('body', '{}')) if isinstance(event.get('body'), str) else event.get('body', {})
        action = body.get('action', 'start').lower()  # Default action: start

        instance_id = get_instance_id()

        if not instance_id:
            logger.info("No existing instance found, launching a new one...")
            response = ec2.run_instances(
                ImageId=AMI_ID,
                InstanceType=INSTANCE_TYPE,
                SubnetId=SUBNET_ID,
                KeyName=KEY_NAME,
                MinCount=1,
                MaxCount=1,
                TagSpecifications=[{
                    'ResourceType': 'instance',
                    'Tags': [{'Key': 'Name', 'Value': INSTANCE_TAG_NAME}]
                }]
            )
            instance_id = response['Instances'][0]['InstanceId']
            logger.info(f"New EC2 instance created in private subnet: {instance_id}")

        else:
            if action == 'start':
                ec2.start_instances(InstanceIds=[instance_id])
                logger.info(f"EC2 instance {instance_id} started successfully")
            elif action == 'stop':
                ec2.stop_instances(InstanceIds=[instance_id])
                logger.info(f"EC2 instance {instance_id} stopped successfully")
            else:
                return {
                    "statusCode": 400,
                    "headers": {"Content-Type": "application/json"},
                    "body": json.dumps({"error": "Invalid action. Use 'start' or 'stop'."})
                }

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": f"EC2 instance {instance_id} {action}ed successfully"})
        }

    except Exception as e:
        logger.error(f"Error in Lambda execution: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }
