cut -d ";" -f 1,4,7 | sed -e 's:STR_ESID:ESID:g' |  sed -e 's:COM_FOSNR:GDENR:g' |  sed -e 's:STR_TYPE:STRTYPE:g' > esid_type.csv
