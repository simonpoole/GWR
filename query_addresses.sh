#! /bin/bash -v

echo processing BFS $1
pgsql2shp -g loc -f /tmp/$1 gis "select EGID, EGAID, GDENR, GDENAME, STRNAME, DEINR, PLZ4, PLZZ, PLZNAME, STRSP, loc from gwr_addresses g, planet_osm_polygon p where p.boundary='administrative' and p.admin_level='8' and tags->'swisstopo:BFS_NUMMER'='$1' and ST_Contains(ST_Transform(p.way,4326),g.loc) and DEINR is not NULL and NOT DEINR LIKE('%.%') and doffadr and g.gstat = 1004 and NOT (gkat = 1010 or gkat = 1080 or gklas = 1242 or gklas = 1252)"
cd /tmp
rm -f /var/www/qa/addresses/GWR/$1.zip
zip /var/www/qa/addresses/GWR/$1.zip $1.*
~simon/osm/GWR/gwr2geojson.pl $1
#geojsontoosm $1.geojson | sed 's/^<osm/<osm upload="never"/' > $1.osm
#geojsontoosm $1_all.geojson | sed 's/^<osm/<osm upload="never"/' > $1_all.osm
java -cp /home/simon/osm/GWR/geojson2osm.jar ch.poole.osm.geojson2osm.Convert -i $1.geojson  > $1.osm
java -cp /home/simon/osm/GWR/geojson2osm.jar ch.poole.osm.geojson2osm.Convert -i $1_all.geojson  > $1_all.osm
rm -f /var/www/qa/addresses/GWR/$1.geojson.zip
zip /var/www/qa/addresses/GWR/$1.geojson.zip $1.geojson
rm -f /var/www/qa/addresses/GWR/$1.osm.zip
zip /var/www/qa/addresses/GWR/$1.osm.zip $1.osm
rm -f /var/www/qa/addresses/GWR/$1_all.geojson.zip
zip /var/www/qa/addresses/GWR/$1_all.geojson.zip $1_all.geojson
rm -f /var/www/qa/addresses/GWR/$1_all.osm.zip
zip /var/www/qa/addresses/GWR/$1_all.osm.zip $1_all.osm
rm -f /tmp/$1.*
