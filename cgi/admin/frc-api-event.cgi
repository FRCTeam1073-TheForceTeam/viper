#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use File::Slurp;
use Data::Dumper;
use lib '../../pm';
use webutil;
use frcapi;
use csv;

my $webutil = webutil->new;
my $frcapi = frcapi->new;
my $cgi = CGI->new;
my $event = $cgi->param('event');
my $first = $cgi->param('first');

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$first = $event if (!$first);
$webutil->error("Malformed first event ID", $first) if ($first !~ /^20[0-9]{2}\/?[a-zA-Z0-9\-]+$/);
$event=lc($event);
$first=lc($first);
my ($eventYear,$eventId) = $first =~/^(20[0-9]{2})\/?([a-zA-Z0-9\-]+)$/;

my $filesWritten = 0;
$filesWritten += $frcapi->writeFileFromAPI("$eventYear/events?eventCode=$eventId","../data/$event.info.json");
$filesWritten += $frcapi->writeFileFromAPI("$eventYear/schedule/$eventId?tournamentLevel=qualification","../data/$event.schedule.qualification.json");
$filesWritten += $frcapi->writeFileFromAPI("$eventYear/schedule/$eventId?tournamentLevel=playoff","../data/$event.schedule.playoff.json");
$filesWritten += $frcapi->writeFileFromAPI("$eventYear/scores/$eventId/qualification","../data/$event.scores.qualification.json");
$filesWritten += $frcapi->writeFileFromAPI("$eventYear/scores/$eventId/playoff","../data/$event.scores.playoff.json");
$filesWritten += $frcapi->writeFileFromAPI("$eventYear/teams?eventCode=$eventId","../data/$event.teams.json");
$webutil->error("API returned no data") if ($filesWritten==0);

if ( ! -e "../data/$event.schedule.csv"){
	$webutil->redirect("/import-frc-api-event.html#event=$event");
}
$webutil->redirect("/frc-event-downloaded.html#event=$event");
