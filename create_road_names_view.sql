create materialized view road_names as select distinct strsp as lang,gdekt as canton,ggdenr as muni_ref,dplz4 as plz4,dplzz as plz2,strname as name,stroffiziel as official,strtype as geom,gwr_entrances.esid from gwr_entrances join gwr_buildings on gwr_entrances.EGID = gwr_buildings.EGID join esid_type on gwr_entrances.ESID = esid_type.esid with data;
CREATE INDEX road_names_gdenr_idx ON public.road_names USING btree (muni_ref);
