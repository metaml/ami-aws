import asyncio as aio
import asyncpg
import boto3
import json
import text as t
import time
import traceback

def handler(event, context):
  print("analytics")
  analytics(event['Records'])
  print("conversation_update: itm -> stm")
  conversation_update(event['Records'])
  print("analytics handler finished")

def conversation_update(recs):
  async def update():
    try:
      u, p, h, db = t.credentials()
      c = await asyncpg.connect(user=u, password=p, database=db, host=h)
      for rec in recs:
        crec = await conversation_ids(rec)
        for id in crec['ids']:
          print("- id=", id)
          await c.execute('update conversation set message_state=$2 where id=$1', id, 'stm')
      await c.close()
    except Exception as e:
      print("exception:", e)
      print(traceback.print_exc())
  return aio.run(update())

def analytics(recs):
  async def insert():
    try:
      u, p, h, db = t.credentials()
      c = await asyncpg.connect(user=u, password=p, database=db, host=h)
      for rec in recs:
        crec = await conversation_ids(rec)
        print("- rec=", rec)
        meta_data = await t.analyze(crec['ids'])
        for meta in meta_data:
          member_id = crec['member'].strip()
          friend_id = crec['friend'].strip()
          last_id = max(crec['ids'])
          mtype = meta[0]
          mdata = meta[1]['choices'][0]['message']['content'].splitlines()
          mdata = list(filter(lambda l: l != '', mdata))
          await c.execute('''insert into conversation_meta
                             (member_id, friend_id, last_conversation_id, meta_type, meta_data)
                             values ($1, $2, $3, $4, $5::jsonb)
                             on conflict do nothing''',
                          member_id,
                          friend_id,
                          last_id,
                          mtype,
                          json.dumps(mdata)
                         )
      await c.close()
    except Exception as e:
      print("exception:", e)
      print(traceback.print_exc())
  return aio.run(insert())

async def conversation_ids(rec):
  bucket = rec['s3']['bucket']['name']
  key = rec['s3']['object']['key']
  content = await s3_object(bucket, key)
  return json.loads(content)

async def s3_object(bucket, key):
  s3 = boto3.resource('s3')
  obj = s3.Object(bucket, key)
  return obj.get()['Body'].read().decode('utf-8')

if __name__ == '__main__':
  event = { 'Records': [ { 'eventVersion': '2.1',
                           'eventSource': 'aws:s3',
                           'awsRegion': 'us-east-2',
                           'eventTime': '2024-10-06T21:28:05.302Z',
                           'eventName': 'ObjectCreated:Put',
                           'userIdentity': { 'principalId': 'AWS:AROA6GBMGVUYCUISS43SC:michael.lee' },
                           'requestParameters': { 'sourceIPAddress': '50.68.120.205'},
                           'responseElements': { 'x-amz-request-id': 'KC5RMJMFP4YNPPX1',
                                                 'x-amz-id-2': 'B7HUl/gOChBl32PD3NBLOfnEEvt6pYqSwEjD9I1SbFZwu2dl5Yn0nkSYQ5rGYZULidRxwf/ATZw0vKoocdT2kgGbUGmF6HllIjJlON++sYA='},
                           's3': { 's3SchemaVersion': '1.0',
                                   'configurationId': 'tf-s3-lambda-20241005012650891900000001',
                                   'bucket': { 'name': 'aip-recomune-us-east-2',
                                               'ownerIdentity': { 'principalId': 'AXOASQHD2KOVH' },
                                               'arn': 'arn:aws:s3:::aip-recomune-us-east-2'
                                              },
                                   'object': { 'key': 'analytics/2024/10/5/conversation.json',
                                               'size': 287,
                                               'eTag': '7f089cb16dfda3c5a008e300917fca95',
                                               'sequencer': '00670300E5322754A7'
                                              }
                                  }
                       } ]
          }
  handler(event, None)
