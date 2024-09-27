BEGIN;
  create table if not exists member (
  	 id serial not null primary key,
	 email text not null unique,
	 password text not null,
	 first_name text not null,
	 last_name text not null,
	 disabled boolean not null default TRUE,
	 created_at timestamptz not null default now()
  );
COMMIT;
