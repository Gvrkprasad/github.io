import json
import boto3

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    try:
        records = event.get('Records', [])
        for record in records:
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            event_time = record['eventTime']
            event_name = record['eventName']

            # Prepare a detailed message
            message = (
                f"Event: {event_name}\n"
                f"Bucket: {bucket_name}\n"
                f"Object: {object_key}\n"
                f"Time: {event_time}\n"
            )

            # Send the message to SNS
            sns_client.publish(
                TopicArn='arn:aws:sns:ap-south-1:471112932176:s3_sns_lamda_topic',
                Message=message,
                Subject="S3 Object Upload Notification"
            )

        return {"statusCode": 200, "body": json.dumps("Notification Sent")}
    except Exception as e:
        print(f"Error: {str(e)}")
        return {"statusCode": 500, "body": json.dumps(f"Error: {str(e)}")}
