#!/usr/bin/perl

use strict;
use utf8;
# load module
use DBI;
local $| = 1;


#
my $muni_ref = $ARGV[0];

open my $out, "> /tmp/$muni_ref".".geojson";
open my $outall, "> /tmp/$muni_ref"."_all.geojson";

binmode($out, ":utf8");
binmode($outall, ":utf8");

# connect
my $dbh = DBI->connect("DBI:Pg:dbname=gis", "www-data", "" , {'RaiseError' => 1});

my $ah = $dbh->prepare("select esid,strtype from esid_type where gdenr=".$muni_ref);
$ah->execute();

my %road_geoms;

while(my $aref = $ah->fetchrow_hashref())
{
	$road_geoms{$aref->{'esid'}} = $aref->{'strtype'};
}

my $bh  = $dbh->prepare("select strname, deinr, plz4, plzname, ST_AsGeoJSON(loc) as geom, esid from gwr_addresses g, planet_osm_polygon p where p.boundary='administrative' and p.admin_level='8' and tags->'swisstopo:BFS_NUMMER'='".$muni_ref."' and ST_Contains(ST_Transform(p.way,4326),g.loc)");
$bh->execute();
header($out);
header($outall);
my $bref = $bh->fetchrow_hashref();
while($bref)
{
	my $housenumber = $bref->{'deinr'};
        output($outall, $bref, $housenumber);
        my $realNumber = not $housenumber =~ /.*\..*/;
	if ($realNumber) {
        	output($out, $bref, $housenumber);
	}
        if ($bref = $bh->fetchrow_hashref()) {
            print $outall ",\n";
            if ($realNumber) {
            	print $out ",\n";
            }
	}
}
print $outall "]}\n";
close $outall;
print $out "]}\n";
close $out;

$dbh->disconnect();

sub header {
        my $handle = $_[0];
	print $handle "{\"type\":\"FeatureCollection\",\n";
	print $handle "\"features\":[\n";
}

sub output {
        my $handle = $_[0];
        my $cursor = $_[1]; 
        my $housenumber = $_[2];

	print $handle "{\"type\":\"Feature\",\n";
	print $handle "\"properties\":{";
        print $handle "\"addr:housenumber\":\"$housenumber\",";
	my $streetname = $cursor->{'strname'};
        my $esid = $cursor->{'esid'};
	my $street_type = $road_geoms{$esid};
        if ($street_type eq 'Area' or $street_type eq 'Place') {
        	print $handle "\"addr:place\":\"$streetname\",";
        } else {
        	print $handle "\"addr:street\":\"$streetname\",";
	}
        print $handle "\"addr:postcode\":\"$cursor->{'plz4'}\",";
        print $handle "\"addr:city\":\"$cursor->{'plzname'}\"";
	print $handle "},\n";
	print $handle "\"geometry\":".$cursor->{'geom'}."\n"; 
	print $handle "}";
}
