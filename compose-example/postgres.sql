/*
 * These commands create a new PostGres SQL database for archiving.
 *
 * https://github.com/ControlSystemStudio/phoebus/blob/master/services/archive-engine/dbd/postgres_schema.txt
 *
 */

------------------------

DROP DATABASE IF EXISTS archive;

CREATE DATABASE archive;

\connect archive

------------------------
-- Sample engine
CREATE SEQUENCE smpl_eng_engid_seq;

DROP TABLE IF EXISTS archive_schema;
CREATE TABLE archive_schema(
   id SERIAL PRIMARY KEY,
   version VARCHAR(10)
);

DROP TABLE IF EXISTS smpl_eng;
CREATE TABLE  smpl_eng
(
   eng_id BIGINT NOT NULL PRIMARY KEY DEFAULT nextval('smpl_eng_engid_seq'),
   name VARCHAR(100) NOT NULL,
   descr VARCHAR(100) NOT NULL,
   url VARCHAR(100) NOT NULL
);
INSERT INTO smpl_eng VALUES (1, 'Demo', 'Demo Engine', 'http://localhost:4812');
SELECT * FROM smpl_eng;

------------------------
-- Retention
-- Not used at this time
CREATE SEQUENCE retent_retentid_seq;

DROP TABLE IF EXISTS retent;
CREATE TABLE  retent
(
   retent_id BIGINT NOT NULL PRIMARY KEY DEFAULT nextval('retent_retentid_seq'),
   descr VARCHAR(255) NOT NULL
);
INSERT INTO retent VALUES (30, 'Months');
INSERT INTO retent VALUES (9999, 'Forever');
SELECT * FROM retent;

------------------------
-- Channel Group

CREATE SEQUENCE chan_grp_grpid_seq;

DROP TABLE IF EXISTS chan_grp;
CREATE TABLE  chan_grp
(
   grp_id BIGINT NOT NULL PRIMARY KEY DEFAULT nextval('chan_grp_grpid_seq'),
   name VARCHAR(100) NOT NULL,
   eng_id BIGINT NOT NULL,
   descr VARCHAR(100) NULL,
   enabling_chan_id BIGINT NULL
);
INSERT INTO chan_grp VALUES (1, 'Demo', 1, 'Demo Group', NULL);
SELECT * FROM chan_grp;

------------------------
-- Sample modes
DROP TABLE IF EXISTS smpl_mode;
CREATE TABLE  smpl_mode
(
   smpl_mode_id BIGINT NOT NULL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   descr VARCHAR(100) NOT NULL
);
INSERT INTO smpl_mode VALUES (1, 'Monitor', 'Store every received update');
INSERT INTO smpl_mode VALUES (2, 'Scan', 'Periodic scan');
SELECT * FROM smpl_mode;

------------------------
-- Channel: ID and name
CREATE SEQUENCE channel_chid;

DROP TABLE IF EXISTS channel;
CREATE TABLE  channel
(
   channel_id BIGINT NOT NULL PRIMARY KEY DEFAULT nextval('channel_chid'),
   name VARCHAR(100) NOT NULL,
   descr VARCHAR(100) NULL,
   grp_id BIGINT NULL,
   smpl_mode_id BIGINT NULL,
   smpl_val double precision NULL,
   smpl_per double precision NULL, 
   retent_id BIGINT NULL,
   retent_val DOUBLE precision NULL
);

-- Need index on channel name
CREATE INDEX channel_name_idx ON channel ( name );

INSERT INTO channel(channel_id, name) VALUES (1, 'sim://sine(0, 10, 50, 0.1)');
INSERT INTO channel(channel_id, name) VALUES (2, 'sim://noiseWaveform(0,10,100,10)');
INSERT INTO channel(channel_id, name) VALUES (3, 'freddy');
INSERT INTO channel(channel_id, name) VALUES (4, 'jane');
UPDATE channel SET retent_val=9999 WHERE channel_id < 4;
UPDATE channel SET grp_id=1 WHERE channel_id < 4;
UPDATE channel SET smpl_val=1 WHERE channel_id = 1;
SELECT * FROM channel;

------------------------
-- Severity mapping of severity ID to string
CREATE SEQUENCE severity_sevid; 

DROP TABLE IF EXISTS severity;
CREATE TABLE severity
(
   severity_id BIGINT NOT NULL PRIMARY KEY default nextval('severity_sevid'),
   name VARCHAR(100) NOT NULL
);
INSERT INTO severity VALUES (1, 'OK'), (2, 'MINOR'), (3, 'MAJOR'), (4, 'INVALID');
SELECT * FROM severity;

------------------------
-- Status mapping of status ID to string
create sequence status_statid;
DROP TABLE IF EXISTS status;
CREATE TABLE  status
(
   status_id BIGINT PRIMARY KEY default nextval('status_statid'),
   name VARCHAR(100) NOT NULL UNIQUE
);
INSERT INTO status (name) VALUES ('OK'), ('disconnected');
SELECT * FROM status;

------------------------
-- Samples of a channel
-- Either the numeric, floating point or string value should be set,
-- not all of them.
--
-- See array_encoding.txt for handling of array data.
DROP TABLE IF EXISTS sample;
CREATE TABLE sample
(
   channel_id BIGINT NOT NULL,
   smpl_time TIMESTAMP NOT NULL,
   nanosecs BIGINT  NOT NULL,
   severity_id BIGINT NOT NULL,
   status_id BIGINT  NOT NULL,
   num_val INT NULL,
   float_val double precision NULL,
   str_val VARCHAR(120) NULL,
   datatype CHAR(1) NULL DEFAULT ' ',
   array_val BYTEA  NULL,
   
   -- Note that these foreign keys are good for data consistency,
   -- but bad for performance.
   -- Writing to the table will be almost twice as fast without
   -- the following constraints
   FOREIGN KEY (channel_id) REFERENCES channel (channel_id) ON DELETE CASCADE,
   FOREIGN KEY (severity_id) REFERENCES severity (severity_id) ON DELETE CASCADE,
   FOREIGN KEY (status_id) REFERENCES status (status_id) ON DELETE CASCADE
);

-- Need index on channel_id and smpl_time?
CREATE INDEX sample_id_time ON sample ( channel_id, smpl_time, nanosecs );

-- These inserts are in reverse time order to check retrieval
INSERT INTO sample (channel_id, smpl_time,  nanosecs, severity_id, status_id, float_val)
   VALUES (1, '2004-01-10 13:01:17', 1,  3, 2, 3.16),
          (1, '2004-01-10 13:01:11', 2,  1, 1, 3.16),
          (1, '2004-01-10 13:01:10', 3, 1, 2, 3.15),
          (1, '2004-01-10 13:01:10', 4, 1, 2, 3.14);

------------------------
-- *** OLD Array element table. Replaced by array_val BLOB in sample table ***
-- See sample table: Array elements 1, 2, 3, ... beyond the element 0
-- that's in the sample table
DROP TABLE IF EXISTS array_val;
CREATE TABLE  array_val
(
   channel_id BIGINT  NOT NULL,
   smpl_time TIMESTAMP NOT NULL,
   nanosecs BIGINT  NOT NULL,
   seq_nbr BIGINT  NOT NULL,
   float_val double precision NULL,
   FOREIGN KEY (channel_id) REFERENCES channel (channel_id) ON DELETE CASCADE
);

CREATE INDEX array_val_id_time ON array_val ( channel_id, smpl_time, nanosecs );


------------------------
-- Channel Meta data: Units etc. for numeric channels
DROP TABLE IF EXISTS num_metadata;
CREATE TABLE  num_metadata
(
   channel_id BIGINT  NOT NULL PRIMARY KEY,
   low_disp_rng double precision NULL,
   high_disp_rng double precision NULL,
   low_warn_lmt double precision NULL,
   high_warn_lmt double precision NULL,
   low_alarm_lmt double precision NULL,
   high_alarm_lmt double precision NULL,
   prec INT NULL,
   unit VARCHAR(100) NOT NULL
);
INSERT INTO num_metadata VALUES (1, 0, 10, 2, 8, 1, 9, 2, 'mA');
SELECT * FROM num_metadata;

------------------------
-- Enumerated channels have a sample.num_val that can also be interpreted
-- as an enumeration string via this table
DROP TABLE IF EXISTS enum_metadata;
CREATE TABLE enum_metadata
(
   channel_id BIGINT  NOT NULL,
   enum_nbr INT NULL,
   enum_val VARCHAR(120) NULL,
   FOREIGN KEY (channel_id) REFERENCES channel (channel_id) ON DELETE CASCADE
);

------------------------
------------------------
------------------------
-- Dump all values for all channels
SELECT channel.name, smpl_time, severity.name, status.name, float_val
   FROM channel, severity, status, sample 
   WHERE channel.channel_id = sample.channel_id AND
         severity.severity_id = sample.severity_id AND
         status.status_id = sample.status_id
   ORDER BY channel.name, smpl_time
   LIMIT 50;

-- Same with INNER JOIN
SELECT channel.name AS channel,
       smpl_time,
       severity.name AS severity,
       status.name AS status,
       float_val
   FROM sample INNER JOIN channel ON sample.channel_id = channel.channel_id INNER JOIN severity ON sample.severity_id = severity.severity_id INNER JOIN status
   ON sample.status_id = status.status_id
   ORDER BY smpl_time
   LIMIT 50;
   
-- Create 'archive' user who can remotely access the 'archive' tables,
-- but only change the table layout locally
--
-- Assume you are connected as the 'postgres' super user

CREATE USER archive WITH PASSWORD '$archive';
ALTER USER archive WITH PASSWORD '$archive';

CREATE USER report WITH PASSWORD '$report';

SELECT * FROM pg_user;


GRANT SELECT, INSERT, UPDATE, DELETE
  ON smpl_eng, retent, smpl_mode, chan_grp, channel, status, severity, sample, array_val, num_metadata, enum_metadata 
  TO archive;

GRANT SELECT
  ON smpl_eng, retent, smpl_mode, chan_grp, channel, status, severity, sample, array_val, num_metadata, enum_metadata 
  TO report;

-- Might have to check with \d which sequences were
-- created by Postgres to handle the SERIAL columns:
GRANT USAGE ON SEQUENCE
  chan_grp_grpid_seq, channel_chid, retent_retentid_seq,
  severity_sevid, smpl_eng_engid_seq, status_statid 
  TO archive;
