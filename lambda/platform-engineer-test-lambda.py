import json
import urllib.parse
import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    bucket_b = 'genomics-platform-engineer-test-bucket-b'
    bucket_a =  event['Records'][0]['s3']['bucket']['name']
    key      =  urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        s3.copy_object(CopySource={'Bucket': bucket_a, 'Key': key}, Bucket=bucket_b, Key=key, Metadata={}, MetadataDirective='REPLACE')
        print('LOG: Success, copied and stripped object {} from bucket {}. to bucket {}'.format(key, bucket_a, bucket_b))
    except Exception as e:
        print('LOG: Error copying object {} from bucket {}. to bucket {}'.format(key, bucket_a, bucket_b))
        print(e)
        raise e
