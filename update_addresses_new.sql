truncate gwr_buildings;
\copy gwr_buildings from gebaeude_batiment_edificio.csv delimiter E'\t' csv header;
truncate gwr_entrances;
\copy gwr_entrances from eingang_entree_entrata.csv delimiter E'\t' csv header;
