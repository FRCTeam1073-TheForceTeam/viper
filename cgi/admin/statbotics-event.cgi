#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use File::Slurp;
use JSON;
use LWP::UserAgent;
use lib '../../pm';
use webutil;
use db;

my $webutil = webutil->new;
my $db = db->new();
my $cgi = CGI->new;
my $event = $cgi->param('event');
my $sbevent = $cgi->param('sbevent');

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$webutil->error("Missing sbevent ID") if (!$sbevent);
$webutil->error("Malformed sbevent ID", $sbevent) if ($sbevent !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$sbevent = lc($sbevent);

my $ua = LWP::UserAgent->new;
$ua->agent('Viper Scouting');

my $url = "https://api.statbotics.io/v3/team_events?event=$sbevent&limit=1000";

my $req = HTTP::Request->new('GET', $url);
my $response = $ua->request($req);

$webutil->error("Statbotics API Error", "Error fetching $url: " . $response->message() . "\n\nRefresh this page to try fetching from the API again.")
	if ($response->is_error());

my $content = $response->content();
my $data = eval { decode_json($content) };

$webutil->error("Statbotics API Error", "Invalid JSON response from Statbotics API")
	if ($@);

if (!defined $data || (ref($data) eq 'ARRAY' && scalar(@$data) == 0)) {
	$webutil->error("Statbotics API Error", "No data returned for event $sbevent from Statbotics API. Verify the event code is correct.");
}

# Write the EPA data to database or file
my $filepath = "../data/$event.epa.json";

if ($db->dbConnection()) {
	$db->upsert('apijson', {
		'event' => $event,
		'file' => 'epa',
		'json' => $content,
	});
	$db->commit();
} else {
	$webutil->error("Error opening $filepath for writing", "$!") if (!open my $fh, ">", $filepath);
	print $fh $content;
	close $fh;
}

$webutil->redirect("/event.html#$event");
