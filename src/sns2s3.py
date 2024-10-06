from datetime import date
import boto3
import json
import time

def handler(event, context):
  print(f"handler event: {event}")
  print(f"handler context: {context}")
  for rec in event['Records']:
    print(f"handler writing: {rec}")
    write_to_s3(rec)
    print(f"handler wrote rec")

def write_to_s3(rec):
  day = date.today()
  try:
    msg = rec['Sns']['Message']
    s3 = boto3.resource("s3")
    print(f"write_to_s3: make obj")
    obj = s3.Object("aip-recomune-us-east-2", f"conversation/{day.year}/{day.month}/{day.day}/{tick()}.json")
    print(f"write_to_s3: made obj={msg}")
    obj.put(Body=msg)
    print(f"wrote_to_s3: put finished")
    print(f"message: {msg}")
  except Exception as x:
    print(f"error: {x}")
    raise x

def tick():
  return time.time_ns()//1_000_000
