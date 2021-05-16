FROM postgres:13.3

#ENV POSTGRES_DB=archive

# SQL to initialize the DB
COPY 01_postgres_schema.sql /docker-entrypoint-initdb.d/
COPY 02_users.sql           /docker-entrypoint-initdb.d/
COPY 03_permissions.sql     /docker-entrypoint-initdb.d/
