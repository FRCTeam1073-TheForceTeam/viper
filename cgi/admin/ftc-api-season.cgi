#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;
use ftcapi;

my $webutil = webutil->new;
my $ftcapi = ftcapi->new;
my $cgi = CGI->new;
my $season = $cgi->param('season');

$webutil->error("Missing year") if (!$season);
$webutil->error("Malformed year", $season) if ($season !~ /^20[0-9]{2}-[0-9]{2}$/);
my ($year) = $season =~ /^(20[0-9]{2})/;

my $filesWritten = 0;
$filesWritten += $ftcapi->writeFileFromAPI("$year","../data/$season.season.json");
$filesWritten += $ftcapi->writeFileFromAPI("$year/events","../data/$season.events.json");
$webutil->error("API returned no data") if ($filesWritten==0);

$webutil->redirect("/api-events.html#$season");
