-- Enter migration here

create extension if not exists plpgsql with schema pg_catalog;
create extension if not exists "uuid-ossp" with schema public;
create extension if not exists citext with schema public;
create extension if not exists pgcrypto with schema public;
create extension if not exists unaccent with schema public;
create extension if not exists pgjwt with schema public;;

-- Reset
drop schema if exists :PRIVATE_SCHEMA cascade;
drop schema if exists :PUBLIC_SCHEMA cascade;
drop schema if exists :FRONT_SCHEMA cascade;
drop schema if exists :ADMIN_SCHEMA cascade;
drop schema if exists app_utils cascade;
drop schema if exists app_types cascade;

revoke all on schema public from public;
alter default privileges revoke all on sequences from public;
alter default privileges revoke all on functions from public;

create schema :PRIVATE_SCHEMA;
create schema :PUBLIC_SCHEMA;
create schema :FRONT_SCHEMA;
create schema :ADMIN_SCHEMA;
create schema app_utils;
create schema app_types;

grant all on schema public to :DATABASE_OWNER;
grant usage on schema public, :PUBLIC_SCHEMA, :FRONT_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types to :PERSON_ROLE;
grant usage on schema :PUBLIC_SCHEMA to :ANON_ROLE;

alter default privileges in schema public, :PUBLIC_SCHEMA, :FRONT_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types grant usage, select on sequences to :PERSON_ROLE;
alter default privileges in schema public, :PUBLIC_SCHEMA, :FRONT_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types grant execute on functions to :PERSON_ROLE;
alter default privileges in schema public, :PUBLIC_SCHEMA grant execute on functions to :ANON_ROLE;


--!include app-utils/slugify.sql

drop table if exists :PRIVATE_SCHEMA.artworks;
create table :PRIVATE_SCHEMA.artworks (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text not null,
  description text,
  slug text not null generated always as (app_utils.slugify(name)) stored,
  name_in_native_language text not null,
  date_format text not null,
  currency text not null,
  is_published boolean not null default false,
  file text
);

create or replace view :ADMIN_SCHEMA.artworks as (
  select * from :PRIVATE_SCHEMA.artworks
);

create or replace view :FRONT_SCHEMA.artworks as (
  select * from :PRIVATE_SCHEMA.artworks
);

grant all on table 
  :ADMIN_SCHEMA.artworks,
  :FRONT_SCHEMA.artworks
to :PERSON_ROLE;


create table if not exists :PRIVATE_SCHEMA.users (
  id       uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  email    text unique not null check ( email ~* '^.+@.+\..+$' ),
  pass     text not null check (length(pass) < 512),
  role     name not null check (length(role) < 512)
);

--!include app-utils/check-role-exists.sql

drop trigger if exists ensure_user_role_exists on :PRIVATE_SCHEMA.users;
create constraint trigger ensure_user_role_exists
  after insert or update on :PRIVATE_SCHEMA.users
  for each row
  execute procedure app_utils.check_role_exists();


--!include app-utils/encrypt-password.sql

drop trigger if exists encrypt_password on :PRIVATE_SCHEMA.users;
create trigger encrypt_password
  before insert or update on :PRIVATE_SCHEMA.users
  for each row
  execute procedure app_utils.encrypt_pass();


--!include app-utils/user-role.sql

CREATE TYPE app_utils.jwt_token AS (
  token text
);

create or replace function :PUBLIC_SCHEMA.login(email text, pass text) returns app_utils.jwt_token as $$
declare
  _role name;
  result app_utils.jwt_token;
begin
  -- check email and password
  select app_utils.user_role(email, pass) into _role;
  if _role is null then
    raise invalid_password using message = 'invalid user or password';
  end if;

  select sign(
      row_to_json(r), 'reallyreallyreallyreallyverysafe'
    ) as token
    from (
      select _role as role, login.email as email,
         extract(epoch from now())::integer + 60*60 as exp
    ) r
    into result;
  return result;
end;
$$ language plpgsql security definer;


-- Create a singup function with minimum right...
-- create or replace function :PUBLIC_SCHEMA.signup(email text, pass text) returns app_utils.jwt_token as $$
--
-- $$ language plpgsql security definer;

grant execute on function :PUBLIC_SCHEMA.login(text,text) to :ANON_ROLE;
