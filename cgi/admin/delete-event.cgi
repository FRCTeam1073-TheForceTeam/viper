#!/usr/bin/perl -w

# Deletes all of the csv files associated with an event, from the database when configured or from the data directory otherwise

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;
use db;
use dbimport;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new();
my $dbimport = dbimport->new;

$webutil->error("Deleting an event requires POST") if ($cgi->request_method ne 'POST');
my $event = $cgi->param('event');
$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$webutil->error("Confirmation must match the event ID") if (($cgi->param('confirm')||"") ne $event);

my @types = qw(event schedule alliances pit subjective scouting);

my $dbh = $db->dbConnection();

if ($dbh){
	for my $type (@types){
		$dbimport->deleteCsvFile("$event.$type.csv", 0);
	}
	$db->commit();
} else {
	for my $type (@types){
		my $file = "../data/$event.$type.csv";
		unlink($file) if (-e $file);
	}
}

$webutil->redirect("/");
