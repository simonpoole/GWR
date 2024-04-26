#! /bin/csh

cd /var/www/qa/addresses/ch/
/home/simon/osm/GWR/address_stats_ch_gwr.pl > new_list.html
cp list.html list-`date +%F`.html
mv new_list.html list.html
cp addressstats_gwr.png addressstats_gwr-`date +%F`.png
/home/simon/osm/GWR/generate_image_addressstats_gwr.py



