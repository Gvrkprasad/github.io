import json
import pymysql
import boto3
import os

# Load database credentials from Lambda environment variables
DB_HOST = os.environ['DATABASE_URL']
DB_USER = os.environ['DB_USERNAME']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

# SNS Topic ARN (Replace with your SNS Topic ARN)
SNS_TOPIC_ARN = os.environ['SNS_TOPIC']

# Connect to MySQL Database
def connect_db():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# Lambda handler function
def lambda_handler(event, context):
    try:
        # Parse incoming request body
        body = json.loads(event['body'])
        name = body.get('name')
        mobileNumber = body.get('mobileNumber')
        date = body.get('date')
        timeSlot = body.get('timeSlot')
        instaId = body.get('instaId', '')  # Optional field

        # Validate input
        if not name or not mobileNumber or not date or not timeSlot:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing required fields"})
            }

        # Insert data into MySQL
        connection = connect_db()
        with connection.cursor() as cursor:
            sql = """INSERT INTO bookings (name, mobileNumber, date, timeSlot, instaId) 
                     VALUES (%s, %s, %s, %s, %s)"""
            cursor.execute(sql, (name, mobileNumber, date, timeSlot, instaId))
            connection.commit()

        # Send SMS confirmation via SNS
        sns_client = boto3.client('sns')
        message = f"Your box cricket booking is confirmed for {date} at {timeSlot}. See you soon!"
        sns_client.publish(PhoneNumber=mobileNumber, Message=message)

        admin_message = f"New Booking Alert! \nName: {name}\nMobile: {mobileNumber}\nDate: {date}\nTime Slot: {timeSlot}\nInstagram: {instaId}"
        sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=admin_message, Subject="New Booking Entry")

        # Success response
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "http://playandfit.s3-website.ap-south-1.amazonaws.com",
                "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "*",
                "Access-Control-Expose-Headers": "*"
            },  
            "body": json.dumps({"message": "Booking successful! SMS sent."})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if 'connection' in locals():
            connection.close()
