-- Enter migration here

create extension if not exists plpgsql with schema pg_catalog;
create extension if not exists "uuid-ossp" with schema public;
create extension if not exists citext with schema public;
create extension if not exists pgcrypto with schema public;
create extension if not exists unaccent with schema public;

-- Reset
drop schema if exists :PRIVATE_SCHEMA cascade;
drop schema if exists :FRONT_SCHEMA cascade;
drop schema if exists :ADMIN_SCHEMA cascade;
drop schema if exists app_utils cascade;
drop schema if exists app_types cascade;

revoke all on schema public from public;
alter default privileges revoke all on sequences from public;
alter default privileges revoke all on functions from public;

create schema :PRIVATE_SCHEMA;
create schema :FRONT_SCHEMA;
create schema :ADMIN_SCHEMA;
create schema app_utils;
create schema app_types;

grant all on schema public to :DATABASE_OWNER;
grant usage on schema public, :FRONT_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types to :PERSON_ROLE;
grant usage on schema :FRONT_SCHEMA to :ANON_ROLE;

alter default privileges in schema public, :FRONT_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types grant usage, select on sequences to :PERSON_ROLE;
alter default privileges in schema public, :FRONT_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types grant execute on functions to :PERSON_ROLE;

/*
 * Schema APP_UTILS
 */
create or replace function app_utils.slugify(v text) returns text as $$
begin
  -- 1. trim trailing and leading whitespaces from text
  -- 2. remove accents (diacritic signs) from a given text
  -- 3. lowercase unaccented text
  -- 4. replace non-alphanumeric (excluding hyphen, underscore) with a hyphen
  -- 5. trim leading and trailing hyphens
  return trim(BOTH '-' FROM regexp_replace(lower(public.unaccent(trim(v))), '[^a-z0-9\\-_]+', '-', 'gi'));
end;
$$ language PLPGSQL strict immutable ;


/*
 * products Table
 */
create table if not exists :PRIVATE_SCHEMA.artworks (
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
