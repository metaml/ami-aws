import asyncio
import asyncpg
import boto3
import json
import socket as s
import time
import traceback

def handler(event, context):
  print(f"in s32rds handler, event={event}")
  u,p,h = credentials()
  print(f"in s32rds handler, got credential")
  insert_dialog(u, p, h, event['Records'])

def insert_dialog(u, p, h, recs):
  async def insert():
    try:
      print('#### u=', u)
      print('#### h=', h)
      print('#### ip=', s.gethostbyname(h))
      print('#### myip=', s.gethostbyname(s.gethostname()))
      c = await asyncpg.connect(user=u, password=p, database='aip', host=h)
      print('#### got DB connection')
      for rec in recs:
        bucket = rec['s3']['bucket']['name']
        key = rec['s3']['object']['key']
        content = s3_object(bucket, key)
        msg = json.loads(content)
        print('######## msg=', msg)
        line = msg['content']
        speaker_type = None
        if msg['role'] == 'assistant':
          speaker_type = 'friend'
        else:
          speaker_type = 'member'
        await c.execute('insert into conversation (member_id, friend_id, friend_type, speaker_type, line, message, message_state) values ( $1, $2, $3, $4, $5, $6, $7)',
                  msg['member'],
                  msg['friend'],
                  'human',
                  speaker_type,
                  line,
                  json.dumps(msg),
                  'itm'
                )
      await c.close()
    except Exception as e:
      print("exception:", e)
      print(traceback.print_exc())
  asyncio.run(insert())

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
  return u

def passwd(sec):
  return sec.get_secret_value(SecretId='db-password')
