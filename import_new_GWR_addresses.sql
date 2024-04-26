truncate table gwr_addresses;
\copy gwr_addresses(EGID,GDEKT,GDENR,GDENAME,GKODE,GKODN,EDID,ESID,STRNAME,DEINR,STRSP,PLZ4,PLZZ,PLZNAME) from 'CH_converted.csv' DELIMITER ';' CSV HEADER;
UPDATE gwr_addresses
SET loc = ST_Transform(ST_GeomFromText('POINT(' || GKODE || ' ' || GKODN || ')', 2056), 4326);
truncate table gwr_address_counts;
insert into gwr_address_counts select GDENR, count(GDENR) from gwr_addresses where DEINR <> '' AND NOT DEINR LIKE '%.%' group by GDENR;

