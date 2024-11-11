#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;
use frcapi;

my $webutil = webutil->new;
my $frcapi = frcapi->new;
my $cgi = CGI->new;
my $year = $cgi->param('year') || $cgi->param('season');

$webutil->error("Missing year") if (!$year);
$webutil->error("Malformed year", $year) if ($year !~ /^20[0-9]{2}$/);

my $filesWritten = 0;
$filesWritten += $frcapi->writeFileFromAPI("$year","../data/$year.season.json");
$filesWritten += $frcapi->writeFileFromAPI("$year/events","../data/$year.events.json");
$filesWritten += $frcapi->writeFileFromAPI("$year/districts","../data/$year.districts.json");
$webutil->error("API returned no data") if ($filesWritten==0);

$webutil->redirect("/api-events.html#$year");
