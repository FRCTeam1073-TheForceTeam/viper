#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Fcntl qw(:flock SEEK_END);
use JSON qw(decode_json encode_json);
use lib '../../pm';
use webutil;
use db;

# Saves the alliance-selection pick list for one event, so it survives a reload
# and is the same on every tab and device. Living under /admin/ is what limits
# writing to an administrator: Apache refuses this path to anyone else. The
# saved file is served from /data/ like the rest of the event data, so scouts
# and guests can see the list without being able to change it.

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new();

my $event = $cgi->param('event');
$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);

my $picklist = $cgi->param('picklist');
$webutil->error("Missing pick list") if (!defined $picklist or $picklist eq "");

my $parsed = eval{decode_json($picklist)};
$webutil->error("Pick list is not in JSON format", "$@") if ($@);
$webutil->error("Expected a JSON object") if (ref $parsed ne ref {});
for my $key (keys %{$parsed}){
	$webutil->error("Unexpected field", $key) if ($key !~ /^(pl|dnp)$/);
	$webutil->error("Expected an array for '$key'") if (ref $parsed->{$key} ne ref []);
	for my $team (@{$parsed->{$key}}){
		$webutil->error("Team number is not a positive integer", $team) if (!defined $team or $team !~ /^[0-9]{1,6}$/);
	}
}
$parsed->{'pl'} = [] if (!exists $parsed->{'pl'});
$parsed->{'dnp'} = [] if (!exists $parsed->{'dnp'});

# A team belongs to one list or the other, never both.
my %inPl = map { $_ => 1 } @{$parsed->{'pl'}};
for my $team (@{$parsed->{'dnp'}}){
	$webutil->error("Team is in both lists", $team) if ($inPl{$team});
}

my $dbh = $db->dbConnection();

if ($dbh){
	# One row per team per position: the ordering is the whole point of a pick
	# list, so it is stored as rows like every other event dataset rather than as
	# a blob. Replaced wholesale, since a save is always the complete list.
	$db->deletePickList($event);
	for my $list ('pl', 'dnp'){
		my $rank = 0;
		for my $team (@{$parsed->{$list}}){
			$db->upsert('picklist', {
				'event' => $event,
				'list'  => $list,
				'rank'  => ++$rank,
				'team'  => $team,
			});
		}
	}
	$db->commit();
	print "Content-type: text/plain;charset=UTF-8\n\n";
	print "OK";
	exit 0;
}

my $fileName = "../data/${event}.picklist.json";
my $lockFile = "$fileName.lock";
open(my $lock, '>', $lockFile) or $webutil->error("Cannot open $lockFile", "$!\n");
flock($lock, LOCK_EX) or $webutil->error("Cannot lock $lockFile", "$!\n");
$webutil->error("Error opening $fileName for writing", "$!") if (!open my $fh, ">", $fileName);
# Normalise last: the checks above stringify these scalars as a side effect, and
# a scalar that has been used as a string encodes as "254" rather than 254.
print $fh encode_json({
	pl  => [map { $_ + 0 } @{$parsed->{'pl'}}],
	dnp => [map { $_ + 0 } @{$parsed->{'dnp'}}],
});
close $fh;
# Deliberately not tracked in revision history: this is saved on every click
# during alliance selection, which would bury the history of the real event data
# under hundreds of commits. Undo on the stats page covers a misclick instead.
close $lock;
unlink($lockFile);

print "Content-type: text/plain;charset=UTF-8\n\n";
print "OK";
