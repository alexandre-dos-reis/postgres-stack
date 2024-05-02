#!/bin/bash
set -e

if [[ "$APP_ENV" == "development" ]]; then
	echo -e "\nCreating database shadow for graphile migrate :\n"
	PGPASSWORD=$POSTGRES_PASS psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		  drop database if exists ${DB_DATABASE_SHADOW};
		  create database ${DB_DATABASE_SHADOW};
	EOSQL
fi
