import os
import json
import boto3
import cfnresponse

client = boto3.client('s3')

def handler(event, context):
    print("Event received:", json.dumps(event))

    source_bucket = os.environ['SOURCE_BUCKET']
    destination_bucket = os.environ['DEST_BUCKET']

    try:
        response = client.list_objects_v2(Bucket=source_bucket)
        if 'Contents' not in response:
            print("No files to copy.")
            return

        for obj in response['Contents']:
            file_key = obj['Key']

            # Copy file
            copy_source = {'Bucket': source_bucket, 'Key': file_key}
            client.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=file_key)
            print(f"Copied {file_key} to {destination_bucket}")

    except Exception as e:
        print("Error:", str(e))

    return {"status": "completed"}
