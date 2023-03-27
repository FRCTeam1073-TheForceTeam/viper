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
my $year = $cgi->param('year');

$webutil->error("Missing year") if (!$year);
$webutil->error("Malformed year", $year) if ($year !~ /^20[0-9]{2}$/);

$frcapi->writeFileFromAPI("$year","../data/$year.season.json");
$frcapi->writeFileFromAPI("$year/events","../data/$year.events.json");
$frcapi->writeFileFromAPI("$year/districts","../data/$year.districts.json");

$webutil->redirect("/fms-events.html#$year");
