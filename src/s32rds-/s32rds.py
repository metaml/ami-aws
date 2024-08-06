import boto3
import json
import psycopg
import time

def handler(event, context):
  for rec in event['Records']:
    print(rec)
  u,p = credentials()

def credentials():
  sec = boto3.client(service_name='secretsmanager', region_name='us-east-2')
  u = user(sec)
  p = passwd(sec)
  return u,p

def user(sec):
  u = sec.get_secret_value(SecretId='db-user')
  return u

def passwd(sec):    
  p = sec.get_secret_value(SecretId='db-password')
  return p
