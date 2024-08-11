import asyncio
import asyncpg
import boto3
import json
import time

def handler(event, context):
  u,p,h = credentials()
  insert_dialog(u, p, h, event['Records'])

def insert_dialog(u, p, h, recs):
  async def insert():
    try:
      c = await asyncpg.connect(user=u, password=p, database='aip', host=h)
      for rec in recs:
        bucket = rec['s3']['bucket']['name']
        key = rec['s3']['object']['key']
        content = s3_object(bucket, key)
        obj = json.loads(content)
        line = obj['line']
        await c.execute('insert into conversation (member_id, friend_id, friend_type, speaker_type, line) values ($1, $2, $3, $4, $5)',
                        'john.smith',
                        'michael.lee',
                        'human',
                        'member',
                        line)
      await c.close()
    except Exception as e:
      print(e)
  asyncio.run(insert())

def s3_object(bucket, key):
  s3 = boto3.resource('s3')
  obj = s3.Object(bucket, key)
  return obj.get()['Body'].read().decode('utf-8')

def credentials():
  sec = boto3.client(service_name='secretsmanager', region_name='us-east-2')
  u = user(sec)
  p = passwd(sec)
  return u['SecretString'], p['SecretString'], "aip.c7eaoykysgcc.us-east-2.rds.amazonaws.com"

def user(sec):
  return sec.get_secret_value(SecretId='db-user')
  return u

def passwd(sec):    
  return sec.get_secret_value(SecretId='db-password')
