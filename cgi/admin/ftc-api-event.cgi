#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use File::Slurp;
use Data::Dumper;
use lib '../../pm';
use webutil;
use ftcapi;
use csv;
use db;

my $webutil = webutil->new;
my $ftcapi = ftcapi->new;
my $db = db->new();
my $cgi = CGI->new;
my $event = $cgi->param('event');
my $first = $cgi->param('first');

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}-[0-9]{2}[a-zA-Z0-9\-]+$/);
if (!$first){
	$first = $event;
	$first =~ s/^(20[0-9]{2})-[0-9]{2}([a-zA-Z0-9\-]+)$/$1\/$2/g;
}
$webutil->error("Malformed first event ID", $first) if ($first !~ /^20[0-9]{2}\/?[a-zA-Z0-9\-]+$/);
$event=lc($event);
$first=lc($first);
my ($eventYear,$eventId) = $first =~/^(20[0-9]{2})\/?([a-zA-Z0-9\-]+)$/;

my $dbh = $db->dbConnection();

my $filesWritten = 0;
$filesWritten += $ftcapi->writeFileFromAPI("$eventYear/events?eventCode=$eventId","../data/$event.info.json");
$filesWritten += $ftcapi->writeFileFromAPI("$eventYear/schedule/$eventId?tournamentLevel=qual","../data/$event.schedule.qualification.json");
$filesWritten += $ftcapi->writeFileFromAPI("$eventYear/schedule/$eventId?tournamentLevel=playoff","../data/$event.schedule.playoff.json");
$filesWritten += $ftcapi->writeFileFromAPI("$eventYear/scores/$eventId/qual","../data/$event.scores.qualification.json");
$filesWritten += $ftcapi->writeFileFromAPI("$eventYear/scores/$eventId/playoff","../data/$event.scores.playoff.json");
$filesWritten += $ftcapi->writeFileFromAPI("$eventYear/teams?eventCode=$eventId","../data/$event.teams.json");
$webutil->error("API returned no data") if ($filesWritten==0);

my $scheduleExists = 0;
if ($dbh){
	my $sth = $dbh->prepare("SELECT * FROM `schedule` WHERE `site`=? AND `event`='$event'");
	$sth->execute($db->getSite());
	my $data = $sth->fetchall_arrayref();
	$scheduleExists = scalar(@$data);
} elsif (-e "../data/$event.schedule.csv"){
	$scheduleExists = 1
}

$webutil->redirect("/import-api-event.html#event=$event") if (!$scheduleExists);
$webutil->redirect("/event-downloaded.html#event=$event");
