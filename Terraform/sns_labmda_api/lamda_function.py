import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

TABLE_NAME = os.environ['booking_table']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        name = body['name']
        phone_number = body['phone_number']
        booking_date = body['date']
        time_slot = body['time_slot']

        # Insert data into DynamoDB
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(
            Item={
                'phone_number': phone_number,
                'name': name,
                'booking_date': booking_date,
                'time_slot': time_slot
            }
        )

        # Send SMS Notification
        sns.publish(
            TopicArn='SNS_TOPIC_ARN',
            Message=f"Booking Confirmed for {name}. Date: {booking_date}, Time Slot: {time_slot}",
            Subject="Booking Confirmation"
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Booking saved successfully!'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f"Error: {str(e)}"})
        }
