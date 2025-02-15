import boto3
region = 'ap-south-1'
instances = ['i-0056d8c0c3b334fd8']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))

    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))