BEGIN;
  create schema if not exists aip;
  create extension if not exists "uuid-ossp";
COMMIT;
