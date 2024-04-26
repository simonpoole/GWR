#!/usr/bin/perl

while (<>) {
        chomp:
	($ei_s_id, $s_n, $lang, $kanton, $bfs_id, $plz4, $plz_z, $name, $abb, $wtf0, $dummy, $official, $type, $wtf1, $num, $date) = split("\t");
	print $lang,"\t",$kanton,"\t",$bfs_id,"\t",$plz4,"\t",$plz_z,,"\t",$name,"\t",$official,"\t",$type,"\n";
}
