select gwr_entrances.egid,edid,gdekt,ggdenr as gdenr,ggdename as gdename,strname,deinr,dplz4 as plz4,dplzz as plzz,dplzname as plzname,coalesce(dkode,gkode) as gkode,coalesce(dkodn,gkodn) as gkodn,strsp,esid from gwr_entrances join gwr_buildings on gwr_entrances.EGID = gwr_buildings.EGID;
