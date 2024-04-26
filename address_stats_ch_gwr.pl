#!/usr/bin/perl

use strict;
# load module
use DBI;
local $| = 1;

binmode(STDOUT, ":utf8");

# connect
my $dbh = DBI->connect("DBI:Pg:dbname=gis", "www-data", "" , {'RaiseError' => 1});


my $second;
my $minute;
my $hour;
my $dayOfMonth;
my $month;
my $yearOffset;
my $dayOfWeek;
my $dayOfYear;
my $daylightSavings;

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = gmtime(time);

print "<H3>Updated - ",(1900+$yearOffset),"-",(1+ $month),"-", $dayOfMonth,"</H3>\n";

print "<table class=\"sortable\">\n";
 
print "<tr><th>Municipality</th><th>GWR Data</th><th class=\"sorttable_numeric\">GWR</th><th class=\"sorttable_numeric\">%GWR</th><th class=\"sorttable_numeric\">Total</th><th class=\"sorttable_numeric\">Buildings</th><th class=\"sorttable_numeric\">Nodes</th></tr>";

my $ah = $dbh->prepare("select distinct osm_id,name,muni_ref  from buffered_boundaries b order by name");
$ah->execute();

my $total_addresses = 0;
my $total_buildings = 0;
my $total_nodes = 0;
my $total_gwr = 0;
open LH, ">>data.txt";

while(my $aref = $ah->fetchrow_hashref())
{
	my $osm_id = $aref->{'osm_id'};
	my $name = $aref->{'name'};
	my $muni_ref = $aref->{'muni_ref'};
 
	my $gwrh =  $dbh->prepare("select count from gwr_address_counts where GDENR=".$muni_ref);
        $gwrh->execute();
        my $gwrref = $gwrh->fetchrow_hashref();
        my $gwr_count = $gwrref->{'count'};
	$total_gwr = $total_gwr + $gwr_count;
	print STDERR $name,"\n";
	print "<tr><td>",$name,"</td><td align=\"center\"><a href=\"http://qa.poole.ch/addresses/GWR/",$muni_ref,".zip\">S</a> <a href=\"http://qa.poole.ch/addresses/GWR/",$muni_ref,".geojson.zip\">G</a> <a href=\"http://qa.poole.ch/addresses/GWR/",$muni_ref,".osm.zip\">O</a> <a href=\"http://qa.poole.ch/addresses/GWR/",$muni_ref,"_all.geojson.zip\">GA</a> <a href=\"http://qa.poole.ch/addresses/GWR/",$muni_ref,"_all.osm.zip\">OA</a></td><td align=\"right\">",$gwr_count,"</td>";
	my $ch = $dbh->prepare("with mp as (select ST_Buffer(ST_Multi(ST_Collect(way)),-30) as w from planet_osm_polygon where osm_id = '$osm_id') select count(building) as building_count from planet_osm_polygon p,mp where ST_IsValid(p.way) AND not St_IsEmpty(p.way) AND p.building is not NULL AND (p.\"addr:housenumber\" is not NULL   or p.\"addr:housename\" is not NULL  or  exist(p.tags , 'addr:full')  or  exist(p.tags , 'addr:conscriptionnumber')  or exists (select l.way from planet_osm_line l where (l.\"addr:interpolation\" is not NULL)  AND St_Intersects(p.way,l.way))) AND St_IsValid(mp.w) AND St_Covers(mp.w,p.way)");
	my $r = $ch->execute();
	
	my $buildings = 0;
	my $nodes = 0;
	if ($r)
	{
		my $cref = $ch->fetchrow_hashref();
		$buildings = $cref->{'building_count'};

		$ch = $dbh->prepare("select count(p.way) as node_count from planet_osm_point p,buffered_boundaries b where (p.\"addr:housenumber\" is not NULL   or p.\"addr:housename\" is not NULL  or  exist(p.tags , 'addr:full')  or  exist(p.tags , 'addr:conscriptionnumber')) AND St_IsValid(b.way) AND St_Covers(b.way,p.way) and b.osm_id='$osm_id'");

		$r = $ch->execute();
		if ($r)
		{
			$cref = $ch->fetchrow_hashref();
			$nodes = $cref->{'node_count'};
			my $total = $buildings + $nodes;
			if (defined($gwr_count) && ($gwr_count > 0))
			{
				my $density = $total/$gwr_count;
				printf "<td align=\"right\">%3.0f</td>", $density*100;
				my $sh = $dbh->prepare("update muni_address_stats set density=$density where muni_ref=$muni_ref");
        			my $r = $sh->execute();
        			if (undef == $r) {
 					print STDERR "Update for $muni_ref failed\n";
                			$sh = $dbh->prepare("insert into muni_address_stats (muni_ref,density) values($muni_ref,$density)");
                			$r = $sh->execute();
        			}
			}
			else
			{
				print STDERR $muni_ref," no gwr data for $muni_ref\n";
				print "<td align=\"right\">-</td>";
			}


			print "<td align=\"right\">", $total,"</td><td align=\"right\">",$buildings,"</td><td align=\"right\">",$nodes,"</td></tr>\n"; 
		}
		else
		{
			print "<td align=\"right\">-</td><td align=\"right\">", $buildings ,"</td><td align=\"right\">",$buildings,"</td><td>Error</td></tr>\n"; 
		}
	}
	else
	{
		
		print "<td align=\"right\">-</td><td>Error</td><td>Errpr</td><td>Error</td></tr>\n"; 
	}
	$total_addresses = $total_addresses + $buildings + $nodes;
	$total_buildings = $total_buildings + $buildings;;
	$total_nodes = $total_nodes + $nodes;
	
	print LH	(1900+$yearOffset),"-",(1+ $month),"-", $dayOfMonth,"\t",$name,"\t",($buildings+$nodes),"\t",$buildings,"\t",$nodes,"\n";
}
print "<tr class=\"sortbottom\"><td><b>TOTAL</b></td><td></td><td align=\"right\"><b>",$total_gwr,"</b></td><td></td><td><b>", $total_buildings + $total_nodes,"</b></td><td><b>",$total_buildings,"</b></td><td><b>",$total_nodes,"</b></td></tr>"; 

print "</table>\n";
print LH	(1900+$yearOffset),"-",(1+ $month),"-", $dayOfMonth,"\tTOTAL\t\t",$total_addresses,"\t",$total_buildings,"\t",$total_nodes,"\n";

close LH;

$dbh->disconnect();


