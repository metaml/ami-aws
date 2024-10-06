from typing import Annotated
import asyncio as aio
import boto3
import json
import os
import pydantic

clients = {}

async def clients():
  key = os.getenv("OPENAI_API_KEY")
  if key == None:
    key = openai_api_key()

  u, p, h = credentials()
  clients['password-db'] = p
  if os.getenv('MODE') == 'DEV':
    clients['user-db'] = 'aip-dev'
    clients['password-db'] = p
    clients['host-db'] = 'localhost'
    clients['db'] = 'aip-dev'
  else:
    clients['user-db'] = u
    clients['password-db'] = p
    clients['host-db'] = h
    clients['db'] = 'aip'

  client_args = {}
  client_args["api_key"] = key
  clients["openai"] = openai.AsyncOpenAI(**client_args)
  yield
  await clients["openai"].close()

def user(sec):
  return sec.get_secret_value(SecretId='db-user')

def passwd(sec):
  return sec.get_secret_value(SecretId='db-password')

def credentials():
  sec = boto3.client(service_name='secretsmanager', region_name='us-east-2')
  u = user(sec)
  p = passwd(sec)
  c = u['SecretString'], p['SecretString'], "aip.c7eaoykysgcc.us-east-2.rds.amazonaws.com"
  sec.close()
  return c

def openai_api_key() -> str:
  c = boto3.client('secretsmanager')
  s = c.get_secret_value(SecretId='openai-api-key')['SecretString']
  c.close()
  return s

async def conversions(ids: [int]) -> [str]:
  u, p, h, db = clients['user-db'], clients['password-db'], clients['host-db'], clients['db']
  recs = []
  try:
    c = await asyncpg.connect(user=u, password=p, database=db, host=h)
    recs = await c.fetchrow('select * from conversion where id in $1', ids)
    print("######## recs=", recs)
    await c.close()
  except Exception as e:
    print("exception:", e)

  if recs == None:
    return None
  else:
    return [json.loads(r[0]) for r in recs]

class TextRequest(pydantic.BaseModel):
  content: str
  prompt: str

async def post(req: TextRequest) -> str:
  res = await clients["openai"].chat.completions.create(
    model = 'gpt-4o',
    messages = [ { 'role': 'user',
                   'content': f"{req.prompt} '{req.content}'"
                 }
               ],
    temperature = 0.0,
    stream = False
  )
  await clients["openai"].close()
  return res.model_dump()

class TextRequest(pydantic.BaseModel):
  content: str
  prompt: str

async def summary(content: str) -> str:
  return await post(TextRequest(prompt='Summarize the following text very tersely:', content=content))

async def sentiment(content: str) -> str:
  return await post(TextRequest(prompt='Analyze the sentiment of the following text as bullet points:', content=content))

async def details(content: str) -> str:
  return await post(TextRequest(prompt='Extract the fine features of the following text as bullet points:', content=content))

async def themes(content: str) -> str:
  return await post(TextRequest(prompt='Extract the themes from the follwing text as bullet points:', content=content))

async def entities(content: str) -> str:
  return await post(TextRequest(prompt='Extract the named enitites from the following text as bullet points:', content=content))

async def analysis(content: str) -> str:
  return await post(TextRequest(prompt='Generate summaries, themes, sentiments, topics for the following text as bullet points, be accurate, and format the ouput as bullet points.', content=content))

async def events(content: str) -> str:
  return await post(TextRequest(prompt='Extract all the events of following text as bullet points.', content=content))

async def question(content: str) -> str:
  return await post(TextRequest(prompt='Generate a informal light question as a friend based on the content:', content=content))

def analyze(ids: [int]) -> bool:
  c = clients()
  cs = conversions(ids)
