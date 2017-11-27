#! /bin/csh

cd /var/www/qa/ch-roads/old/
/home/simon/osm/GWR/road_stats_old.pl > new_list.html
cp list.html list-`date +%F`.html
mv new_list.html list.html
cp namestats_overall.png namestats_overall-`date +%F`.png
cp namestats_road.png namestats_road-`date +%F`.png
/home/simon/osm/GWR/generate_image_namestats_overall_old.py
/home/simon/osm/GWR/generate_image_namestats_road_old.py

