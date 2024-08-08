import boto3
import json
import time

def handler(event, context):
  for rec in event['Records']:
    write_to_s3(rec)

def write_to_s3(rec):
  try:
    msg = rec['Sns']['Message']
    s3 = boto3.resource("s3")
    obj = s3.Object("aip-recomune-us-east-2", f"michael.lee/dialog/{tick()}.json")
    obj.put(Body=msg)
    print(f"message: {msg}")
  except Exception as x:
    print(f"error: {x}")
    raise x

def tick():
  return time.time_ns()//1_000_000
