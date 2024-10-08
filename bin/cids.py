#!/usr/bin/env python

import asyncio as aio
import asyncpg
import json
import time
import traceback

def handler(event, context):
  update(event['Records'])


if __name__ == "__main__":
  u, p, h, db = credentials()

def credentials():
  s = boto3.client(service_name='secretsmanager', region_name='us-east-2')
  u = s.get_secret_value(SecretId='db-user')
  p = s.get_secret_value(SecretId='db-password')
  s.close()
  if os.getenv('MODE') == None:
    return u['SecretString'], p['SecretString'], 'aip.c7eaoykysgcc.us-east-2.rds.amazonaws.com', 'aip'
  else:
    return 'aip-dev', p['SecretString'], 'localhost','aip-dev'
