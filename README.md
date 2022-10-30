# Using multiple databases with the official PostgreSQL Docker image (wiht multiple dump files)

This fork has added the functionality of adding and execution of dump files to each database.

The [official recommendation](https://hub.docker.com/_/postgres/) for creating
multiple databases is as follows:

*If you would like to do additional initialization in an image derived from
this one, add one or more `*.sql`, `*.sql.gz`, or `*.sh` scripts under
`/docker-entrypoint-initdb.d` (creating the directory if necessary). After the
entrypoint calls `initdb` to create the default `postgres` user and database,
it will run any `*.sql` files and source any `*.sh` scripts found in that
directory to do further initialization before starting the service.*

This directory contains a script to create multiple databases using that
mechanism.

## Usage

### By mounting a volume

Note: do not place sql scripts in 'docker-entrypoint-initdb.d' directory.
In this example they are placed in 'db-scripts' and referenced form *.sh file.


Clone the repository, mount its directory as a volume into
`/docker-entrypoint-initdb.d` and declare database names separated by commas in
`POSTGRES_MULTIPLE_DATABASES` environment variable as follows
(`docker-compose` syntax):

    myapp-postgresql:
        image: postgres:9.6.2
        environment:
			- POSTGRES_MULTIPLE_DATABASES=DB1,ownerOfDB1,db1Dump.sql-DB2,ownerOfDB2,db2Dump.sql-...DB(n),ownerOfDB(n),db(n)Dump.sql
            - POSTGRES_PASSWORD=

	volumes:
      - ./create-multiple-postgresql-databases.sh:/docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh
      - ./db1Dump.sql:/db-scripts/db1Dump.sql
      - ./db2Dump.sql:/db-scripts/db2Dump.sql
	  ...
	  - ./db(n)Dump.sql:/db-scripts/db(n)Dump.sql
	  