
# Example on how to use the Phoebus Archiver with `docker-compose`

### Using PostgreSQL as Database

```bash
docker-compose -f docker-compose.postgres.yml up -d db
# This starts the database in the background

docker-compose -f docker-compose.postgres.yml up configure-db-oneshot
# This will configure the database according to the Example.xml
# It should exit with the following command:
# > phoebus-archiver-configure-db-oneshot exited with code 0

# Now edit `docker-compose.postgres.yml` and move the service
# 'phoebus-archiver-configure-db-oneshot' to the section `x-disabled:`.
# Then start the regular archiver application:

docker-compose -f docker-compose.postgres.yml up -d app

# You should now be able to visit http://localhost:4812/main with
# your browser.
```
