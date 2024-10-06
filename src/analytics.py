import asyncio
import asyncpg
import boto3
import json
import socket as s
import time
import traceback

def handler(event, context):
  print(f"in analytics handler, event={event}")
  u, p, h = credentials()
  print(f"in analytics handler, got credential")
  analytics(u, p, h, event['Records'])

def analytics(u, p, h, recs):
  async def insert():
    try:
      c = await asyncpg.connect(user=u, password=p, database='aip', host=h)
      for rec in recs:
        d = dialog(rec)
        print(d)
      await c.close()
    except Exception as e:
      print("exception:", e)
      print(traceback.print_exc())
  asyncio.run(insert())

def dialog(rec):
  bucket = rec['s3']['bucket']['name']
  key = rec['s3']['object']['key']
  content = s3_object(bucket, key)
  return json.loads(content)

def s3_object(bucket, key):
  s3 = boto3.resource('s3')
  obj = s3.Object(bucket, key)
  return obj.get()['Body'].read().decode('utf-8')

def credentials():
  sec = boto3.client(service_name='secretsmanager', region_name='us-east-2')
  u = user(sec)
  p = passwd(sec)
  h = 'aip.c7eaoykysgcc.us-east-2.rds.amazonaws.com'
  return u['SecretString'], p['SecretString'], h

def user(sec):
  return sec.get_secret_value(SecretId='db-user')

def passwd(sec):
  return sec.get_secret_value(SecretId='db-password')
