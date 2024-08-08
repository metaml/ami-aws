import asyncio
import asyncpg
import boto3
import json
import time

def handler(event, context):
  u,p,h = credentials()
  insert(u, p, h, event['Records'])

def insert_db(u, p, h, recs):
  asyncio.run(insert())
  def async def insert):
    try:
      c = await asyncpg.connect(user=u, password=p, database='aip', host=h)
      await c.execute('insert into dialog (user_id, line) values ($1, $2)',
                      'michael.lee', line
                     )
      await conn.close()
    except Exception as e:
      print(e)

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
  u = sec.get_secret_value(SecretId='db-user')
  return u

def passwd(sec):    
  p = sec.get_secret_value(SecretId='db-password')
  return p
