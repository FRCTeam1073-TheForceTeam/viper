#!/usr/bin/perl

use strict;
use File::Slurp;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../pm";
use csv;

for my $file (@ARGV){
	my $csv = csv->new(scalar(read_file($file, {binmode=>':encoding(UTF-8)'})));
	for my $line (1..$csv->getRowCount()){
		print $csv->getByName($line,"scouter"),"\n";
	}
}
