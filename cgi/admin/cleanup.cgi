#!/usr/bin/perl -w

use strict;
use warnings;

print "Content-type: text/html; charset=UTF-8\n\n";
print "<html><body><h1>Checking for bad data to clean up...</h1><pre>\n";

for my $file (glob("../data/RCS ../data/*.lock")){
	if (-e $file){
		unlink($file);
		print "Deleted $file\n";
	}
}
print "... Done</pre></body></html>\n";
