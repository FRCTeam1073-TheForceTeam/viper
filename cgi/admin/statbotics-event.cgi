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

$webutil->error(
	"Statbotics is temporarily unavailable",
	"We couldn't reach the Statbotics API right now (it responded: " . $response->message() . ").\n\n"
		. "This is almost always a temporary problem on Statbotics' end, not your event data. "
		. "Please wait a little while and try fetching again.",
	"/event.html#$event")
	if ($response->is_error());

my $content = $response->content();
my $data = eval { decode_json($content) };

$webutil->error(
	"Statbotics is temporarily unavailable",
	"Statbotics returned a response we couldn't read. This is usually a temporary problem on their end; please try again shortly.",
	"/event.html#$event")
	if ($@);

if (!defined $data || (ref($data) eq 'ARRAY' && scalar(@$data) == 0)) {
	$webutil->error(
		"No Statbotics data for this event",
		"Statbotics returned no data for event \"$sbevent\". Double-check that the Statbotics event code is correct, or try again later if the event is new.",
		"/event.html#$event");
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

# Also fetch match-level predictions (used for predicted rank calculations)
my $matchesUrl = "https://api.statbotics.io/v3/matches?event=$sbevent&limit=1000";
my $matchesResp = $ua->request(HTTP::Request->new('GET', $matchesUrl));
if (!$matchesResp->is_error()) {
	my $matchesContent = $matchesResp->content();
	if ($db->dbConnection()) {
		$db->upsert('apijson', {
			'event' => $event,
			'file'  => 'statbotics-matches',
			'json'  => $matchesContent,
		});
		$db->commit();
	} else {
		my $matchesPath = "../data/$event.statbotics-matches.json";
		if (open my $fh, ">", $matchesPath) {
			print $fh $matchesContent;
			close $fh;
		}
	}
}

$webutil->redirect("/event.html#$event");
