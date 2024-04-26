truncate esid_type;
\copy esid_type ( ESID , GDENR , STRTYPE ) from 'esid_type.csv' DELIMITER ';' CSV HEADER;
