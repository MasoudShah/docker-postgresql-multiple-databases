#!/bin/bash

set -e
set -u

function create_user_and_database() {
	local database=$(echo $1 | tr ',' ' ' | awk  '{print $1}')
	local owner=$(echo $1 | tr ',' ' ' | awk  '{print $2}')
	local dump=$(echo $1 | tr ',' ' ' | awk  '{print $3}')
	echo "  Creating user and database '$database'"
	echo "  database: '$database'"
	echo "  owner: '$owner'"
	echo "  dump: '$dump'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
		--CREATE USER $owner IF NOT EXISTS;
	    CREATE DATABASE "$database";
	    GRANT ALL PRIVILEGES ON DATABASE "$database" TO $owner;
EOSQL
	echo "  Created database: '$database'"
	echo "  Dump file path: './docker-entrypoint-initdb.d/$dump'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$database" < ./db-scripts/$dump
	echo "  Executed dump script on : '$database'"
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
	for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr '-' ' '); do
		create_user_and_database $db
	done
	echo "Multiple databases created"
fi
