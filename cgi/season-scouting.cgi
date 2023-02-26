#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Data::Dumper;
use File::Slurp;
use lib '../pm';
use webutil;
use csv;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $year = $cgi->param('year');

$webutil->error("Missing year") if (!$year);
$webutil->error("Malformed year", $year) if ($year !~ /^20[0-9]{2}$/);

my $files = [glob("data/${year}*.scouting.csv")];
$webutil->error("No scouting CSV files for year", $year) if (scalar @$files == 0);

my $csv;

print "Content-Type: text/plain; charset=utf-8\n\n";

for my $file (@$files){
	my $contents = read_file("$file");
	my $append = csv->new($contents);
	if (!$csv){
		$csv = $append;
	} else {
		$csv->append($append);
	}
}
print $csv->toString();
