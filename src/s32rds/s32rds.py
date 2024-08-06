import boto3
import json
import time

def handler(event, context):
  for rec in event['Records']:
    print(rec)
