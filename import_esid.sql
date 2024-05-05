truncate esid_type;
\copy esid_type ( ESID , GDENR , STRTYPE , STR_STATUS , STR_OFFICIAL , STR_EASTING , STR_NORTHING ) from 'esid_type.csv' DELIMITER ';' CSV HEADER;
