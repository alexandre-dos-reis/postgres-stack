#!/bin/bash
set -e

echo -e "\n Creating roles...\n"
PGPASSWORD=$POSTGRES_PASS psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	    drop role if exists ${AUTH_ROLE};
	    create role ${AUTH_ROLE} with login password '${AUTH_PASS}' noinherit;

	    drop role if exists ${ANON_ROLE};
	    create role ${ANON_ROLE} nologin;
	    grant ${ANON_ROLE} to ${AUTH_ROLE};

	    drop role if exists ${PERSON_ROLE};
	    create role ${PERSON_ROLE} nologin;
	    grant ${PERSON_ROLE} to ${AUTH_ROLE};
EOSQL
