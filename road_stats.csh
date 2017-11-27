#! /bin/csh

cd /var/www/qa/ch-roads/
/home/simon/osm/GWR/road_stats.pl > new_list.html
cp list.html list-`date +%F`.html
mv new_list.html list.html
cp namestats_overall.png namestats_overall-`date +%F`.png
cp namestats_road.png namestats_road-`date +%F`.png
/home/simon/osm/GWR/generate_image_namestats_overall.py
/home/simon/osm/GWR/generate_image_namestats_road.py


