#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Data::Dumper;
use lib '../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $year = $cgi->param('year');

$webutil->error("Missing year") if (!$year);
$webutil->error("Malformed year", $year) if ($year !~ /^20[0-9]{2}$/);

my $files = [split(/\n/, `ls -t1r data/${year}*.scouting.csv`)];
$webutil->error("No scouting CSV files for year", $year) if (scalar @$files == 0);

print "Content-Type: text/plain; charset=utf-8\n\n";
print `head -n 1 "$files->[0]"`;
for my $file (@$files){
	my $data = `tail -n +2 "$file"`;
	$data = $data."\n" if ($data !~ /\n\Z/);
	print $data;
}
