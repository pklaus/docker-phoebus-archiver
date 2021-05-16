-- Create 'archive' user who can remotely access the 'archive' tables,
-- but only change the table layout locally
--
-- Assume you are connected as the 'postgres' super user

CREATE USER archive WITH PASSWORD '$archive';
ALTER USER archive WITH PASSWORD '$archive';

CREATE USER report WITH PASSWORD '$report';

SELECT * FROM pg_user;
