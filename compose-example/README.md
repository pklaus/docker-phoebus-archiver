
# Docker Compose Template With an EPICS Example IOC

### Using PostgreSQL as Database

Change to this directory and execute the following commands:

```bash
# Start the DB for the first time:
docker-compose -f postgres.yml up db
# You should see your tables being created. If everything is OK,
# you should see the following output within the last 10 lines:
# > PostgreSQL init process complete; ready for start up.
# Quit with Ctrl-C and start the DB again - this time in background:
docker-compose -f postgres.yml up -d db

# Now configure which PVs the archiver should handle,
# i.e. load Example.xml to the database:
docker-compose -f postgres.yml up configure-db-oneshot
# It should exit with the following command:
# > phoebus-archiver-configure-db-oneshot exited with code 0

# Then start the regular archiver application:
docker-compose -f postgres.yml up -d app
```

You should now be able to visit <http://localhost:4812/main> with
your browser.

```
# You may now edit `docker-compose.postgres.yml` and move the service
# 'phoebus-archiver-configure-db-oneshot' to the section `x-disabled:`.
# From then on, you can use
docker-compose -f postgres.yml down
# or
docker-compose -f postgres.yml up
to stop/start all necessary containers.
```
