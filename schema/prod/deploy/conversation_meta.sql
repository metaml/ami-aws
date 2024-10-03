BEGIN;

drop type if exists meta_enum;
create type meta_enum as enum ('detail', 'entity', 'event', 'sentiment', 'summary', 'theme');

create table if not exists conversation_meta (
       id serial not null primary key,
       guid uuid not null unique default uuid_generate_v4(),
       member_id text not null,
       friend_id text not null,
       last_conversation_id integer not null,
       meta_type meta_enum not null,
       meta_data jsonb not null default '[]'::jsonb,
       created_at timestamptz not null default now()
       );

COMMIT;
