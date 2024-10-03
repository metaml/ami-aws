BEGIN;
  drop type if exists speaker_enum;
  create type speaker_enum as enum ('member', 'friend');

  drop type if exists friend_enum;
  create type friend_enum as enum ('human', 'ami');

  drop type if exists message_enum;
  create type message_enum as enum ('itm', 'stm', 'ltm');

  create table if not exists conversation (
  	 id serial not null primary key,
	 guid uuid not null unique default uuid_generate_v4(),
	 member_id text not null,
	 friend_id text not null,
	 friend_type friend_enum not null,
	 speaker_type speaker_enum not null,
	 line text not null,
	 message jsonb not null default '{}'::jsonb,
	 message_state message_enum not null,
	 created_at timestamptz not null default now()
	 );

COMMIT;
