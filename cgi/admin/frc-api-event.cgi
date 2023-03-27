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
my $event = $cgi->param('event');

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$event=lc($event);
my ($eventYear,$eventId) = $event=~/^(20[0-9]{2})([a-zA-Z0-9\-]+)$/;

$frcapi->writeFileFromAPI("$eventYear/events?eventCode=$eventId","../data/$event.info.json");
$frcapi->writeFileFromAPI("$eventYear/schedule/$eventId?tournamentLevel=qualification","../data/$event.schedule.qualification.json");
$frcapi->writeFileFromAPI("$eventYear/schedule/$eventId?tournamentLevel=playoff","../data/$event.schedule.playoff.json");
$frcapi->writeFileFromAPI("$eventYear/scores/$eventId/qualification","../data/$event.scores.qualification.json");
$frcapi->writeFileFromAPI("$eventYear/scores/$eventId/playoff","../data/$event.scores.playoff.json");
$frcapi->writeFileFromAPI("$eventYear/teams?eventCode=$eventId","../data/$event.teams.json");

$webutil->error("Done");
