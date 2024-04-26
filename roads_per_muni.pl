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

        my $lh = $dbh->prepare("select name, plz4, plz2, official, geom from road_names where muni_ref=$muni_ref order by name,plz4,plz2");
        $lh->execute();

	my %GWR_names;
	my %GWR_plz6;
	print MH "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\">\n";
	print MH "<link rel=\"stylesheet\" type=\"text/css\" href=\"../index.css\" />\n";
	print MH "<script src=\"../sorttable.js\"></script>\n";
	print MH "</head><body><H3>Municipality ref ",$muni_ref,"</H3>\n<p>\n";
	print MH "<table class=\"sortable\">\n";

	print MH "<tr><th>GWR Name</th><th>GWR Type</th><th>PLZ6</th><th></th></tr>\n";
        while(my $lref = $lh->fetchrow_hashref()) 
	{
		my $plz4 = $lref->{'plz4'};
		my $plz2 = $lref->{'plz2'};
		my $plz6 = ($plz4 * 100) + $plz2;
		my $name = $lref->{'name'};
		my $geom = $lref->{'geom'};
	        my $official = $lref->{'official'};
		$GWR_plz6{$name} = $plz6;
		print MH "<tr><td>",$name,"</td><td>"; 
		if ($geom eq '9801') {
                       	print MH 'road';
		} elsif ($geom eq '9802') {
                       	print MH 'point';
		} elsif ($geom eq '9803') {
                       	print MH 'area';
		} elsif ($geom eq '9809') {
                       	print MH 'none';
		} else {
                       	print MH 'unknown';
		}
		print MH  "</td><td>",$plz6,"</td><td>";
		if ($official==1) {
			print MH '';
		} elsif ($official==11) {
			print MH 'no addresses';
		} else {
			print MH 'not used ';
		}
		print MH  "</td></tr>\n"; 
	}
	
	print MH "</table></body></html>\n";
	close MH;
}
$dbh->disconnect();

