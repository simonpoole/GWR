

#
#  create table road_names (lang int, canton char(2), muni_ref int, plz4 int, plz2 int, name varchar, official int, geom char(4));
cut -f 3,4,5,6,7,8,12,13 |  iconv -f LATIN1 -t UTF-8  > GWR_import.txt
