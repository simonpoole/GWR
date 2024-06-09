#!/usr/bin/perl -CS

use strict;
# load module
use DBI;

binmode(STDOUT, ":utf8");

my $polygon = -1;
my $muni_ref = -1;
my $canton = "";

# connect
my $dbh = DBI->connect("DBI:Pg:dbname=gis", "www-data", "" , {'RaiseError' => 1});

my $ah = $dbh->prepare("select distinct canton, muni_ref, official from road_names order by canton, muni_ref");
$ah->execute();

while(my $aref = $ah->fetchrow_hashref())
{
	$canton = $aref->{'canton'};
	$muni_ref = $aref->{'muni_ref'};

        print "processing ", $muni_ref, "\n";

	open MH, ">allroads/$muni_ref.html";
        binmode(MH, ":utf8");

        my $lh = $dbh->prepare("select name, plz4, plz2, official, geom , round(ST_X(loc)::numeric,5) as x, round(ST_Y(loc)::numeric,5) as y from road_names where muni_ref=$muni_ref order by name,plz4,plz2");
        $lh->execute();

	my %GWR_names;
	my %GWR_plz6;
	print MH "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\">\n";
	print MH "<link rel=\"stylesheet\" type=\"text/css\" href=\"../index.css\" />\n";
	print MH "<script src=\"../sorttable.js\"></script>\n";
	print MH "</head><body><H3>Municipality ref ",$muni_ref,"</H3>\n<p>\n";
	print MH "<table class=\"sortable\">\n";

	print MH "<tr><th>GWR Name</th><th>GWR Type</th><th>PLZ6</th><th>Status</th><th></th></tr>\n";
        while(my $lref = $lh->fetchrow_hashref()) 
	{
		my $plz4 = $lref->{'plz4'};
		my $plz2 = $lref->{'plz2'};
		my $plz6 = ($plz4 * 100) + $plz2;
		my $name = $lref->{'name'};
		my $geom = $lref->{'geom'};
	        my $official = $lref->{'official'};
                my $x = $lref->{'x'};
                my $y = $lref->{'y'};

		$GWR_plz6{$name} = $plz6;
		print MH "<tr><td>",$name,"</td><td>"; 
		if ($geom eq 'Street')
                {
			print MH "road"; 
                }
                elsif ($geom eq 'Place')
                {
			print MH "point"; 
                }
                elsif ($geom eq 'Area')
                {
			print MH "area"; 
                }
                else
                {
			print MH "unknown"; 
                }

		print MH  "</td><td>",$plz6,"</td><td>";
		if ($official) {
			print MH 'in use';
		} else {
			print MH 'not in use';
		}
                print MH "</td><td><a target=\"_blank\" href=\"https://openstreetmap.org/";
                print MH "?mlat=",$y,"&mlon=",$x;
                print MH "#map=17/",$y,"/",$x;
                print MH "\">",$y," / ",$x,"</a>";
		print MH  "</td></tr>\n"; 
	}
	
	print MH "</table></body></html>\n";
	close MH;
}
$dbh->disconnect();

