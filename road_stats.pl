#!/usr/bin/perl -CS

use strict;
# load module
use DBI;
#use String::Approx qw(amatch asubstitute);
use Text::Levenshtein qw(distance);

binmode(STDOUT, ":utf8");

my $polygon = -1;
my $muni_ref = -1;
my $canton = "";

# connect
my $dbh = DBI->connect("DBI:Pg:dbname=gis", "www-data", "" , {'RaiseError' => 1});

# nodes
my %nodes;
my %highways;
my %ways;
my %polygons;

my $ah;

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
 
print "<tr><th>Canton</th><th>Municipality</th><th>BFS Ref</th><th class=\"sorttable_numeric\">% match<br>overall</th><th class=\"sorttable_numeric\">% match<br>roads</th><th class=\"sorttable_numeric\">Typos</th><th class=\"sorttable_numeric\">OSM Roads</th><th class=\"sorttable_numeric\">OSM Areas</th><th class=\"sorttable_numeric\">OSM Nodes</th><th class=\"sorttable_numeric\">OSM Total</th><th class=\"sorttable_numeric\">GWR Roads</th><th class=\"sorttable_numeric\">GWR Areas</th><th class=\"sorttable_numeric\">GWR Points</th><th class=\"sorttable_numeric\">GWR none</th><th class=\"sorttable_numeric\">GWR unknown</th><th class=\"sorttable_numeric\">GWR Total</th><th>Exact match</th><th>Match dif. type</th><th><small>Match OSM roads<br>GWR none</small></th><th><small>Match OSM roads<br>GWR unknown</small></th><th class=\"sorttable_numeric\">Missing</th></tr>";

$ah = $dbh->prepare("select distinct canton, muni_ref from road_names  where official order by canton, muni_ref");
$ah->execute();

my $total_osm_road_count = 0;
my $total_osm_area_count = 0;
my $total_osm_point_count = 0;
my $total_GWR_road_count = 0;
my $total_GWR_point_count = 0;
my $total_GWR_area_count = 0;
my $total_GWR_none_count = 0;
my $total_GWR_unknown_count = 0;
my $total_exact_count = 0;
my $total_exact_type_count = 0;
my $total_road_match = 0;
my $total_point_match = 0;
my $total_area_match = 0;
my $total_other_match = 0;
my $total_unexact_road_match = 0;
my $total_unknown_road_count = 0;
my $total_none_road_count = 0;


while(my $aref = $ah->fetchrow_hashref())
{
	$canton = $aref->{'canton'};
	$muni_ref = $aref->{'muni_ref'};
	my $mh;

#	$mh = $dbh->prepare("select osm_id, name from planet_osm_polygon where boundary='administrative' and admin_level='8' and tags->'swisstopo:BFS_NUMMER'='$muni_ref' and way && ST_Transform(SetSRID('BOX3D(5.92 45.78,10.55 47.85)'::box3d, 4326),900913)");
	$mh = $dbh->prepare("select osm_id, name from buffered_boundaries where muni_ref='$muni_ref'");
	$mh->execute();

# execute SELECT query

	my $lh;
	my $first_polygon = 1;
	my %osm_names;
	my %osm_names_de;
	my %osm_names_fr;
	my %osm_names_it;
	my %osm_names_rm;
	my %osm_names_alt;
	my %osm_names_official;
	my %osm_names_short;
	my %osm_names_left;
	my %osm_names_right;
	my $osm_road_count = 0;
	my $osm_area_count = 0;
	my $osm_point_count = 0;
	my $muni_name;
	while(my $mref = $mh->fetchrow_hashref()) 
	{
		$polygon = $mref->{'osm_id'};
		if ($first_polygon) 
		{
			$muni_name = $mref->{'name'};
			print "<tr><td>",$canton,"</td><td><A HREF=\"", $canton,"/",$muni_ref,".html\">",$muni_name, "</A> <A HREF=\"http://qa.poole.ch/?osm_id=",$polygon,"\" target=\"noname map\">m</A> <A HREF=\"allroads/",$muni_ref,".html\">all</A></td><td>", $muni_ref,"</td>"; 
			mkdir $canton;
			open MH, ">$canton/$muni_ref.html";
			binmode(MH, ":utf8");
			$first_polygon = 0;
		}

#		roads
		$lh = $dbh->prepare("select distinct l.name, l.tags->'name:de' as name_de,  l.tags->'name:fr' as name_fr, l.tags->'name:it' as name_it , l.tags->'name:rm' as name_rm, l.tags->'alt_name' as alt_name,l.tags->'official_name' as official_name,l.tags->'name:left' as name_left,l.tags->'name:right' as name_right,l.tags->'short_name' as short_name from planet_osm_line l, buffered_boundaries p where (l.highway is not NULL) and p.osm_id = $polygon and ST_Intersects(l.way,p.way)");
		$lh->execute();

		while(my $lref = $lh->fetchrow_hashref()) 
		{
     			$osm_names{$lref->{'name'}} = 'road';
     			$osm_names_de{$lref->{'name_de'}} = 'road';
     			$osm_names_fr{$lref->{'name_fr'}} = 'road';
     			$osm_names_it{$lref->{'name_it'}} = 'road';
     			$osm_names_rm{$lref->{'name_rm'}} = 'road';
     			$osm_names_alt{$lref->{'alt_name'}} = 'road';
     			$osm_names_official{$lref->{'official_name'}} = 'road';
     			$osm_names_left{$lref->{'name_left'}} = 'road';
     			$osm_names_right{$lref->{'name_right'}} = 'road';
     			$osm_names_short{$lref->{'short_name'}} = 'road';

			$osm_road_count++;
		}
#		areas
		print STDERR "Polygon: ",$polygon,"\n";
		$lh = $dbh->prepare("select distinct  l.name, l.tags->'name:de' as name_de,  l.tags->'name:fr' as name_fr, l.tags->'name:it' as name_it , l.tags->'name:rm' as name_rm , l.tags->'alt_name' as alt_name,l.tags->'official_name' as official_name,l.tags->'short_name' as short_name   from planet_osm_polygon l, buffered_boundaries p where ((l.place is not NULL) or (l.highway is not NULL)) and p.osm_id = $polygon and not ST_IsEmpty(l.way) and ST_Intersects(l.way,p.way)");
		$lh->execute();

		while(my $lref = $lh->fetchrow_hashref()) 
		{
     			$osm_names{$lref->{'name'}} = 'area';
     			$osm_names_de{$lref->{'name_de'}} = 'area';
     			$osm_names_fr{$lref->{'name_fr'}} = 'area';
     			$osm_names_it{$lref->{'name_it'}} = 'area';
     			$osm_names_rm{$lref->{'name_rm'}} = 'area';
     			$osm_names_alt{$lref->{'alt_name'}} = 'area';
     			$osm_names_official{$lref->{'official_name'}} = 'area';
     			$osm_names_short{$lref->{'short_name'}} = 'area';

			$osm_area_count++;
		}
		$lh = $dbh->prepare("select distinct  l.name, l.tags->'name:de' as name_de,  l.tags->'name:fr' as name_fr, l.tags->'name:it' as name_it , l.tags->'name:rm' as name_rm, l.tags->'alt_name' as alt_name,l.tags->'official_name' as official_name,l.tags->'short_name' as short_name    from planet_osm_point l, buffered_boundaries p where ((l.place is not NULL)  or (l.junction is not NULL)) and p.osm_id = $polygon and ST_Intersects(l.way,p.way)");
		$lh->execute();

		while(my $lref = $lh->fetchrow_hashref()) 
		{
     			$osm_names{$lref->{'name'}} = 'point';
     			$osm_names_de{$lref->{'name_de'}} = 'point';
     			$osm_names_fr{$lref->{'name_fr'}} = 'point';
     			$osm_names_it{$lref->{'name_it'}} = 'point';
     			$osm_names_rm{$lref->{'name_rm'}} = 'point';
     			$osm_names_alt{$lref->{'alt_name'}} = 'point';
     			$osm_names_official{$lref->{'official_name'}} = 'point';
     			$osm_names_short{$lref->{'short_name'}} = 'point';

			$osm_point_count++;
		}
	}
	# no polygons !
	if ($first_polygon) 
	{
		print "<H2>",$muni_name,"</H2>\n";
		print "<tr><td>",$canton,"</td><td><A HREF=\"", $canton,"/",$muni_ref,".html\">Missing from OSM</A></td><td>", $muni_ref,"</td>"; 
		mkdir $canton;
		open MH, ">$canton/$muni_ref.html";
	}

        $lh = $dbh->prepare("select name, plz4, plz2, official, geom from road_names where muni_ref=$muni_ref and official order by name,plz4,plz2");
        $lh->execute();

	my %GWR_names;
	my %GWR_plz6;
	my %exact_type_match;
	my %exact_match;
	my $GWR_road_count = 0;
	my $GWR_point_count = 0;
	my $GWR_area_count = 0;
	my $GWR_none_count = 0;
	my $GWR_unknown_count = 0;
	my $GWR_unknown_road_count = 0;
	my $GWR_none_road_count = 0;
	my $exact_type_count = 0;
	my $exact_count = 0;
	my $road_match = 0;
	my $unexact_road_match = 0;
	my $area_match = 0;
	my $point_match = 0;
	my $other_match = 0;
	print MH "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\">\n";
	print MH "<link rel=\"stylesheet\" type=\"text/css\" href=\"../index.css\" />\n";
	print MH "<script src=\"../sorttable.js\"></script>\n";
	print MH "</head><body><H3>",$muni_name," ",(1900+$yearOffset),"-",(1+ $month),"-",$dayOfMonth,"</H3>\n<!--#include file=\"legend.html\" -->\n<p>\n";
	print MH "<table class=\"sortable\">\n";

	print MH "<tr><th>GWR Name</th><th>GWR Type</th><th>PLZ6</th><th>Approx. Matches</th><th>Location</th></tr>\n";
        while(my $lref = $lh->fetchrow_hashref()) 
	{
		my $plz4 = $lref->{'plz4'};
		my $plz2 = $lref->{'plz2'};
		my $plz6 = ($plz4 * 100) + $plz2;
		my $name = $lref->{'name'};
		my $name_plz = "$name|$plz6";
		my $geom = $lref->{'geom'};
		$GWR_plz6{$name} = $plz6;
		if ($geom eq 'Street')
		{
                       	$GWR_names{$name_plz} = 'road';
			$GWR_road_count++;
		}
		elsif ($geom eq 'Place')
		{
                       	$GWR_names{$name_plz} = 'point';
			$GWR_point_count++;
		}
		elsif ($geom eq 'Area')
		{
                       	$GWR_names{$name_plz} = 'area';
			$GWR_area_count++;
		}
		else
		{
                       	$GWR_names{$name_plz} = 'unknown';
			$GWR_unknown_count++;
		}
		if ( (exists $osm_names{$name}) ||  (exists $osm_names_de{$name}) ||  (exists $osm_names_fr{$name}) ||  (exists $osm_names_it{$name}) ||  (exists $osm_names_rm{$name}) || (exists $osm_names_alt{$name}) ||  (exists $osm_names_official{$name}) ||  (exists $osm_names_left{$name})||  (exists $osm_names_right{$name}) ||  (exists $osm_names_short{$name}))
		{
			my $GWR_type = $GWR_names{$name_plz};
			if (($GWR_type eq  $osm_names{$name}) || ($GWR_type  eq  $osm_names_de{$name}) || ($GWR_type  eq  $osm_names_fr{$name}) || ($GWR_type  eq  $osm_names_it{$name}) || ($GWR_type  eq  $osm_names_rm{$name}) || ($GWR_type  eq  $osm_names_alt{$name}) || ($GWR_type  eq  $osm_names_official{$name}) || ($GWR_type  eq  $osm_names_left{$name}) || ($GWR_type  eq  $osm_names_right{$name})  || ($GWR_type  eq  $osm_names_short{$name}))
			{
				$exact_match{$name_plz} = 1;
				$exact_count++;
				if ($GWR_type  eq 'road')
				{
					$road_match++;
				}
				elsif ($GWR_type  eq 'point')
				{
					$point_match++;
				}
				elsif ($GWR_type  eq 'area')
                                {
                                        $area_match++;
                                }
				else
				{
					$other_match++;
				}
			} elsif ($GWR_type  eq 'unknown') {
				# check if it is a OSM road
				if ( ($osm_names{$name} eq 'road') ||  ($osm_names_de{$name} eq 'road') ||  ($osm_names_fr{$name} eq 'road') ||  ($osm_names_it{$name} eq 'road') ||  ($osm_names_rm{$name} eq 'road') || ($osm_names_alt{$name} eq 'road') ||  ($osm_names_official{$name} eq 'road') ||  ($osm_names_left{$name} eq 'road')||  ($osm_names_right{$name} eq 'road') ||  ($osm_names_short{$name} eq 'road')) {
					$exact_type_match{$name_plz} = 1;
                                	$exact_count++;
					$road_match++;
					# fudge the original numbers
					$GWR_road_count++;
					if ($GWR_type  eq 'unknown') {
						$GWR_unknown_count--;
						$GWR_unknown_road_count++;
					} else {
						$GWR_none_count--;
                                                $GWR_none_road_count++;
					}			
				} else {
				 	$exact_type_match{$name_plz} = 1;
                               		$exact_type_count++;
                                }
			}
			else
			{
				$exact_type_match{$name_plz} = 1;
				$exact_type_count++;
				if ($GWR_names{$name_plz} eq 'road') {
					$unexact_road_match++;
				}
			}
		}
	}
	# more stats muning
	if ($GWR_road_count == $GWR_unknown_road_count) { # didn't report any roads but has some
		$GWR_road_count = $GWR_road_count +  $GWR_unknown_count;
		$GWR_unknown_count = 0;
	} elsif ($GWR_road_count == $GWR_none_road_count) {
		$GWR_road_count = $GWR_road_count +  $GWR_none_count;
                $GWR_none_count = 0;
	} elsif ($GWR_road_count == ($GWR_unknown_road_count + $GWR_none_road_count)) {
		$GWR_road_count = $GWR_road_count + $GWR_unknown_count + $GWR_none_count;
		$GWR_unknown_count = 0;
		$GWR_none_count = 0;
	}
	
	my $typos = 0;
        $lh = $dbh->prepare("select name, plz4, plz2, official, geom, round(ST_X(loc)::numeric,5) as x, round(ST_Y(loc)::numeric,5) as y from road_names where muni_ref=$muni_ref and official order by name,plz4,plz2");
        $lh->execute();
        while(my $lref = $lh->fetchrow_hashref()) 
	{
		my $plz4 = $lref->{'plz4'};
		my $plz2 = $lref->{'plz2'};
		my $plz6 = ($plz4 * 100) + $plz2;
		my $name = $lref->{'name'};
		my $geom = $lref->{'geom'};
		my $name_plz = "$name|$plz6";
                my $x = $lref->{'x'};
                my $y = $lref->{'y'};
		if ((! exists $exact_type_match{$name_plz}) && (! exists $exact_match{$name_plz}))
		{
			print MH "<tr><td>",$name,"</td><td>",$GWR_names{$name_plz},"</td><td>",$plz6,"</td><td>\n";
			# find approx matches
			my $first = 1;
			my $dist = 3;
			foreach my $key (keys %osm_names)
			{
				my $d = distance(lc $name,lc $key);
				if ($d <= $dist)
				{
					if ($first == 0) { print MH ",";}
					$first = 0;
					my $key_plz = "$key|$plz6";
					if (exists  $exact_match{$key_plz}  )
					{
						print MH "X:",$key;
					}
					elsif (exists  $exact_type_match{$key_plz} )
					{
						print MH "T:",$key;
					}
					elsif ($d <= 1)
					{
						print MH "<font color=\"#FF0000\">",$key,"</font>";
						$typos++;
					}
					else
					{
						print MH $key;
					}
				}
			}
			foreach my $key (keys %osm_names_de)
			{
				my $d = distance(lc $name,lc $key);
				if ($d <= $dist)
				{
					if ($first == 0) { print MH ",";}
					$first = 0;
					if (exists  $exact_match{$key}  )
					{
						print MH "X:";
					}
					if (exists  $exact_type_match{$key} )
					{
						print MH "T:";
					}
					if ($d <= 1)
					{
						print MH "<font color=\"#FF0000\">",$key,"</font>";
						$typos++;
					}
					else
					{
						print MH $key;
					}
				}
			}
			foreach my $key (keys %osm_names_fr)
			{
				my $d = distance(lc $name,lc $key);
				if ($d <= $dist)
				{
					if ($first == 0) { print MH ",";}
					$first = 0;
					if (exists  $exact_match{$key}  )
					{
						print MH "X:";
					}
					if (exists  $exact_type_match{$key} )
					{
						print MH "T:";
					}
					if ($d <= 1)
					{
						print MH "<font color=\"#FF0000\">",$key,"</font>";
						$typos++;
					}
					else
					{
						print MH $key;
					}
				}
			}
			foreach my $key (keys %osm_names_it)
			{
				my $d = distance(lc $name,lc $key);
				if ($d <= $dist)
				{
					if ($first == 0) { print MH ",";}
					$first = 0;
					if (exists  $exact_match{$key}  )
					{
						print MH "X:";
					}
					if (exists  $exact_type_match{$key} )
					{
						print MH "T:";
					}
					if ($d <= 1)
					{
						print MH "<font color=\"#FF0000\">",$key,"</font>";
						$typos++;
					}
					else
					{
						print MH $key;
					}
				}
			}
			foreach my $key (keys %osm_names_rm)
			{
				my $d = distance(lc $name,lc $key);
				if ($d <= $dist)
				{
					if ($first == 0) { print MH ",";}
					$first = 0;
					if (exists  $exact_match{$key}  )
					{
						print MH "X:";
					}
					if (exists  $exact_type_match{$key} )
					{
						print MH "T:";
					}
					if ($d <= 1)
					{
						print MH "<font color=\"#FF0000\">",$key,"</font>";
						$typos++;
					}
					else
					{
						print MH $key;
					}
				}
			}
			print MH "</td><td><a target=\"_blank\" href=\"https://openstreetmap.org/";
                        print MH "?mlat=",$y,"&mlon=",$x;
                        print MH "#map=17/",$y,"/",$x;
                        print MH "\">",$y," / ",$x,"</a>"; 
                        print MH "</td></tr>\n";
		}
        }
	print MH "</table></body></html>\n";
	close MH;
#	print	$osm_road_count,"\t",$osm_area_count,"\t",$osm_point_count,"\t",$GWR_road_count,"\t",$GWR_area_count,"\t",$GWR_point_count,"\t",$GWR_none_count,"\t",$GWR_unknown_count,"\t",$exact_type_count,"\t",$exact_count,"\n";
	my $p_overall = -1;
	if (($GWR_road_count + $GWR_area_count + $GWR_point_count + $GWR_none_count + $GWR_unknown_count) > 0)
	{
		$p_overall = (($exact_type_count + $exact_count) / ($GWR_road_count + $GWR_area_count + $GWR_point_count + $GWR_none_count + $GWR_unknown_count)*100); 
		$p_overall = sprintf "%.0f", $p_overall;
		if ($p_overall > 90)
		{
			print	"<td class=\"green\" align=\"right\">",
		}
		elsif ($p_overall > 80)
		{
			print	"<td class=\"orange\" align=\"right\">",
		}
		else
		{
			print	"<td class=\"red\" align=\"right\">",
		}
		print $p_overall,"</td>";
	}
	else
	{
		print "<td class=\"grey\" align=\"right\">-</td>";
	}
	my $p_road = -1;
	if ($GWR_road_count > 0)
	{
		$p_road = (($road_match + $unexact_road_match)/ $GWR_road_count)*100; 
		$p_road = sprintf "%.0f", $p_road;
		if ($p_road > 90)
		{
			print	"<td class=\"green\" align=\"right\">",
		}
		elsif ($p_road > 80)
		{
			print	"<td class=\"orange\" align=\"right\">",
		}
		else
		{
			print	"<td class=\"red\" align=\"right\">",
		}
		print $p_road,"</td>";
	}
	else
	{
		print "<td class=\"grey\" align=\"right\">-</td>";
	}
        my $GWR_total = $GWR_road_count+$GWR_area_count+$GWR_point_count+$GWR_none_count+$GWR_unknown_count;
	print "<td align=\"right\">",$typos,"</td><td align=\"right\">",$osm_road_count,"</td><td align=\"right\">",$osm_area_count,"</td><td align=\"right\">",$osm_point_count,"</td><td class=\"grey\" align=\"right\">",$osm_road_count+$osm_area_count+$osm_point_count,"</td><td align=\"right\">",$GWR_road_count,"</td><td align=\"right\">",$GWR_area_count,"</td><td align=\"right\">",$GWR_point_count,"</td><td align=\"right\">",$GWR_none_count,"</td><td align=\"right\">",$GWR_unknown_count,"</td><td class=\"grey\" align=\"right\">",$GWR_total,"</td><td align=\"right\">",$exact_count,"</td><td align=\"right\">",$exact_type_count,"</td><td align=\"right\">",$GWR_none_road_count,"</td><td align=\"right\">",$GWR_unknown_road_count,"</td><td align=\"right\">",$GWR_total-$exact_count-$exact_type_count,"</td></tr>\n";

	# insert states into DB (overall and road already calculated)
	my $p_point = -1;
	if ($GWR_point_count > 0)
	{
		$p_point = ($point_match / $GWR_point_count)*100; 
		$p_point = sprintf "%.0f", $p_point;
	}		
	my $p_area = -1;
	if ($GWR_area_count > 0)
	{
		$p_area = ($area_match / $GWR_area_count)*100; 
		$p_area = sprintf "%.0f", $p_area;
	}		
	my $p_other = -1;
	if (($GWR_none_count + $GWR_unknown_count) > 0)
	{
		$p_other = ($other_match / ($GWR_none_count + $GWR_unknown_count))*100; 
		$p_other = sprintf "%.0f", $p_other;
	}		
        my $sh = $dbh->prepare("update muni_name_stats set match_overall=$p_overall,match_road=$p_road,match_point=$p_point,match_area=$p_area,match_other=$p_other where muni_ref=$muni_ref");
        my $r = $sh->execute();
        if (undef == $r) {
		print STDERR "Update for $muni_ref failed\n";
        	$sh = $dbh->prepare("insert into muni_name_stats (muni_ref,match_overall,match_road,match_point,match_area,match_other) values($muni_ref,$p_overall,$p_road,$p_point,$p_area,$p_other)");
        	$r = $sh->execute();
        	if (undef == $r) {
			print STDERR "Insert for $muni_ref failed\n";
		} else {
			print STDERR "Insert for $muni_ref was sucessful\n";
		}
	}
	# totals
	$total_osm_road_count = $total_osm_road_count + $osm_road_count;
	$total_osm_area_count = $total_osm_area_count + $osm_area_count;
	$total_osm_point_count = $total_osm_point_count + $osm_point_count;
	$total_GWR_road_count = $total_GWR_road_count + $GWR_road_count;
	$total_GWR_point_count = $total_GWR_point_count + $GWR_point_count;
	$total_GWR_area_count = $total_GWR_area_count  + $GWR_area_count;
	$total_GWR_none_count = $total_GWR_none_count + $GWR_none_count;
	$total_GWR_unknown_count = $total_GWR_unknown_count + $GWR_unknown_count;
	$total_exact_count = $total_exact_count + $exact_count;
	$total_exact_type_count = $total_exact_type_count + $exact_type_count;
	$total_road_match = $total_road_match + $road_match;
	$total_point_match = $total_point_match + $point_match;
	$total_area_match = $total_area_match + $area_match;
	$total_other_match = $total_other_match + $other_match;
	$total_unexact_road_match = $total_unexact_road_match + $unexact_road_match;
	$total_unknown_road_count = $total_unknown_road_count + $GWR_unknown_road_count;
	$total_none_road_count = $total_none_road_count + $GWR_none_road_count;
}

print "</table>\n";

	open LH, ">>data.txt";
	print LH	(1900+$yearOffset),"-",(1+ $month),"-", $dayOfMonth,"\t",$total_osm_road_count,"\t",$total_osm_area_count,"\t",$total_osm_point_count,"\t",$total_GWR_road_count,"\t",$total_GWR_point_count,"\t",$total_GWR_area_count,"\t",$total_GWR_none_count,"\t",$total_GWR_unknown_count,,"\t",$total_exact_count,"\t",$total_exact_type_count,"\t",$total_road_match,"\t",$total_point_match,"\t",$total_area_match,"\t",$total_other_match,"\t",$total_unexact_road_match,"\t",$total_unknown_road_count,"\t",$total_none_road_count,"\n"; 	
	close LH;

$dbh->disconnect();




    sub findApprox {

             my $var = $_[0];
             
     }

