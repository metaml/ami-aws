BEGIN;
  create type speaker_enum as enum ('member', 'friend');
  create type friend_enum as enum ('human', 'aip');

  create table if not exists conversation (
  	 id serial not null primary key,
	 guid uuid not null unique default uuid_generate_v4(),
	 member_id text not null,
	 friend_id text not null,
	 friend_type friend_enum not null,
	 speaker_type speaker_enum not null,	 	 
	 line text not null,
	 message jsonb not null default '{}'::jsonb,
	 created_at timestamptz not null default now()
	 );
	 
COMMIT;
