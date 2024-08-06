import boto3
import json
import psycopg2
import time

def handler(event, context):
  u,p,h = credentials()
  print(u)
  print(h)  
  write_db(u, p, h, event['Records'])

def write_db(u, p, h, recs):
  db = psycopg2.connect(f"dbname='aip' user={u} host={h} password={p}")
  with db:
    with db.cursor() as curs:
      try: 
        for rec in recs:
          bucket = rec['s3']['bucket']['name']
          key = rec['s3']['object']['key']
          content = s3_object(bucket, key)
          obj = json.loads(content)
          line = obj['line']
          curs.execute(f"insert into dialog (user_id, line) values ('michael.lee', '{line}')")
      except (Exception, psycopg2.DatabaseError) as x:
        print(x)

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
