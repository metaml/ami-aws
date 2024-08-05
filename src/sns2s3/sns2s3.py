import boto3
import json
import time

def handler(event, context):
  for rec in event['Records']:
    write_to_s3(rec)

def write_to_s3(rec):
  try:
    msg = record['Sns']['Message']
    s3 = boto3.resource("s3").Bucket("aip-recomune-us-esat-2")
    json.dump_s3(msg, f"michael.lee/dialog/{tick}")
    print(f"message: {msg}")
  except Exception as x:
    print(f"error: {x}")
    raise x

def tick:
  time.time_ns()//1_000_000
