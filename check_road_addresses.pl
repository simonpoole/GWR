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

# nodes

my $ah;

$ah = $dbh->prepare("select distinct  muni_ref,name from road_names  where official=1 order by muni_ref");
$ah->execute();

while(my $aref = $ah->fetchrow_hashref())
{
	my $muni_ref = $aref->{'muni_ref'};
	my $name = $aref->{'name'};
	my $mh;

	$mh = $dbh->prepare("select count(strname) from gwr_addresses where gdenr=$muni_ref and strname=?");
	$mh->execute($name);

	while(my $mref = $mh->fetchrow_hashref()) 
	{
		my $count = $mref->{'count'};
		if ($count == 0) 
		{
        		my $sh = $dbh->prepare("update road_names set official=11 where muni_ref=$muni_ref and name=?");
        		my $r = $sh->execute($name);
        		if (undef == $r) {
				print STDERR "Update for $muni_ref $name failed\n";
			}
		}
	}
}

$dbh->disconnect();

