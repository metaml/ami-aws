from typing import Annotated
import asyncio as aio
import asyncpg
import boto3
import json
import openai
import os
import pydantic

# to change or add the type of text analysis, you need to add a row to conversation_meta table
PROMPTS = [ ('summary',   'Summarize the following dialog very tersely as bullet points'),
            ('sentiment', 'List the sentiments of the following dialog as bullet points'),
            ('detail',    'List the fine features of the following dialog as bullet points'),
            ('theme',     'Listt the themes from the follwing dialog as bullet points'),
            ('entity',    'List named enitites, dates, addresses, etc. from the following dialog as bullet points'),
            ('event',      'List all the events of following dialog as bullet points'),
            #('analysis', 'Generate summaries, themes, sentiments, topics for the following dialog as bullet points, be accurate, and format the ouput as bullet points'),
            #('questions', 'Ask 3 informal light questions as a friend based on the following dialog')
          ]

class TextRequest(pydantic.BaseModel):
  content: str
  prompt: str

async def analyze(ids: [int]) -> [(str, str)]:
  meta_data = []
  dialog = await dialogue(ids)
  client = openai_client()
  for prompt in PROMPTS:
    key = prompt[0]
    meta = await post(TextRequest(prompt=prompt[1], content=dialog), client)
    meta_data.append((key, meta))
  await client.close()
  return meta_data

async def dialogue(ids: [int]) -> str:
  def line(row):
    pair = None
    if row['speaker_type'] == 'member':
      pair = (row['member_id'].strip(), row['line'].strip())
    else:
      pair = (row['friend_id'].strip(), row['line'].strip())
    return pair
  rows = await conversations(ids)
  pairs = list(map(lambda r: line(r), rows))
  lines = list(map(lambda p: f"{p[0]}: {p[1]}", pairs))
  return "\n\n\n".join(lines)

async def metadata(prompt:str, content: str, client) -> str:
  return await post(TextRequest(prompt=prompt, content=content), client)

async def conversations(ids: [int]) -> [str]:
  u, p, h, db = credentials()
  recs = None
  try:
    db = await asyncpg.connect(user=u, password=p, database=db, host=h)
    rows = await db.fetch('select * from conversation where id = any($1::int[])', ids)
    await db.close()
  except Exception as e:
    print("exception:", e)
  if rows == None: return []
  else: return rows

async def post(req: TextRequest, client) -> str:
  client = openai_client()
  res = await client.chat.completions.create(
    model = 'gpt-4o',
    messages = [ { 'role': 'user',
                   'content': f"{req.prompt}: '{req.content}'"
                 }
               ],
    temperature = 0.0,
    stream = False
  )
  return res.model_dump()

def openai_client():
  args = {}
  args['api_key'] = openai_api_key()
  return openai.AsyncOpenAI(**args)

def openai_api_key() -> str:
  c = boto3.client('secretsmanager')
  k = c.get_secret_value(SecretId='openai-api-key')['SecretString']
  c.close()
  return k

def credentials():
  s = boto3.client(service_name='secretsmanager', region_name='us-east-2')
  u = s.get_secret_value(SecretId='db-user')
  p = s.get_secret_value(SecretId='db-password')
  s.close()
  if os.getenv('MODE') == None:
    return u['SecretString'], p['SecretString'], 'aip.c7eaoykysgcc.us-east-2.rds.amazonaws.com', 'aip'
  else:
    return 'aip-dev', p['SecretString'], 'localhost','aip-dev'
