\connect archive

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
