drop materialized view gwr_addresses;
create materialized view gwr_addresses as select gwr_entrances.egid,egaid,gdekt,ggdenr as gdenr,ggdename as gdename,strname,deinr,dplz4 as plz4,dplzz as plzz,dplzname as plzname,coalesce(dkode,gkode) as e,coalesce(dkodn,gkodn) as n,strsp,esid,gkat,gklas,ST_Transform(ST_GeomFromText('POINT(' || coalesce(dkode,gkode) || ' ' || coalesce(dkodn,gkodn) || ')', 2056), 4326) as loc, gstat, doffadr from gwr_entrances join gwr_buildings on gwr_entrances.EGID = gwr_buildings.EGID with data;
CREATE INDEX gwr_addreses_gdenr_idx ON public.gwr_addresses USING btree (gdenr);
CREATE INDEX gwr_addresses_idx ON public.gwr_addresses USING gist (loc);
