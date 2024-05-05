create table esid_type
(
   ESID bigint,
   GDENR integer,
   STRTYPE text,
   STR_STATUS text,
   STR_OFFICIAL text,
   STR_EASTING numeric(12,3),
   STR_NORTHING numeric(12,3)
) tablespace gis;
