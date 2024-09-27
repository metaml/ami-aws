-- Deploy aip:prompt to pg
-- requires: schema

BEGIN;
  create table if not exists prompt (
         id serial not null primary key,
         guid uuid not null unique default uuid_generate_v4(),
 	 prompt text not null,
         member_id text not null,
         friend_id text not null,
	 enabled boolean not null,
         created_at timestamptz not null default now(),
         unique (prompt, friend_id, member_id)
  );

COMMIT;
