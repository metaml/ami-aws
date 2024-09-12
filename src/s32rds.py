import asyncio
import asyncpg
import boto3
import json
import time

def handler(event, context):
  print(f"in s32rds handler, event={event}")
  u,p,h = credentials()
  print(f"in s32rds handler, got credential")
  insert_dialog(u, p, h, event['Records'])

def insert_dialog(u, p, h, recs):
  async def insert():
    try:
      c = await asyncpg.connect(user=u, password=p, database='aip', host=h)
      for rec in recs:
        bucket = rec['s3']['bucket']['name']
        key = rec['s3']['object']['key']
        content = s3_object(bucket, key)
        msg = json.loads(content)
        line = msg['content']
        await c.execute('insert into conversation (member_id, friend_id, friend_type, speaker_type, line, message) values ($1, $2, $3, $4, $5, $6)',
                        'john.smith',
                        'michael.lee',
                        'human',
                        'member',
                        line,
                        json.dumps(msg)
                       )
      await c.close()
    except Exception as e:
      print("exception:", e)
  asyncio.run(insert())

def s3_object(bucket, key):
  s3 = boto3.resource('s3')
  obj = s3.Object(bucket, key)
  return obj.get()['Body'].read().decode('utf-8')

def credentials():
  sec = boto3.client(service_name='secretsmanager', region_name='us-east-2')
  u = user(sec)
  p = passwd(sec)
  h = 'ec2-18-219-36-48.us-east-2.compute.amazonaws.com'
  return u['SecretString'], p['SecretString'], h

def user(sec):
  return sec.get_secret_value(SecretId='db-user')
  return u

def passwd(sec):
  return sec.get_secret_value(SecretId='db-password')
