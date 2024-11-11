#!/usr/bin/perl -w

use strict;
use warnings;
use open ':std', ':encoding(UTF-8)';
use CGI;
use Data::Dumper;
use File::Slurp;
use lib '../pm';
use webutil;
use csv;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $season = $cgi->param('season') || $cgi->param('year');

$webutil->error("Missing season") if (!$season);
$webutil->error("Malformed season", $season) if ($season !~ /^20[0-9]{2}(-[0-9]{2})?$/);

my $files = [glob("data/${season}*.scouting.csv")];
if ($season =~ /^20[0-9]{2}$/){
	$files = [grep {$_ !~ /^20[0-9]{2}-[0-9]{2}$/} @$files];
}
$webutil->error("No scouting CSV files for season", $season) if (scalar @$files == 0);

my $csv;

print "Content-Type: text/plain; charset=utf-8\n\n";

for my $file (@$files){
	my $contents = read_file("$file", {binmode => ':encoding(UTF-8)'});
	my $append = csv->new($contents);
	if (!$csv){
		$csv = $append;
	} else {
		$csv->append($append);
	}
}
print $csv->toString();
