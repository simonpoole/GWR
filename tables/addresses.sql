-- EGID;EDID;GDEKT;GDENR;GDENAME;STRNAME;DEINR;PLZ4;PLZZ;PLZNAME;GKODE;GKODN;STRSP

CREATE TABLE gwr_addresses
(
  EGID bigint,
  EDID bigint,
  GDEKT text,
  GDENR integer,
  GDENAME text,
  STRNAME text,
  DEINR text,
  PLZ4 integer,
  PLZZ integer,
  PLZNAME text,
  GKODE numeric(12,3),
  GKODN numeric(12,3),
  STRSP text,
  loc geometry
) TABLESPACE gis;

CREATE TABLE gwr_address_counts (
    gdenr integer,
    count integer
) TABLESPACE gis;

