#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use File::Slurp;
use LWP::UserAgent;
use POSIX qw/strftime/;
use lib '../../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $event = $cgi->param('event');

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
my ($eventYear,$eventId) = $event=~/^(20[0-9]{2})([a-zA-Z0-9\-]+)$/;

my $localConf = read_file('../../local.conf');
my ($apiUser) = $localConf =~ /^FRC_API_USER\s*=\s*\"?([a-zA-Z0-9\-_]+)\"?\s*$/m;
my ($apiToken) = $localConf =~ /^FRC_API_TOKEN\s*=\s*\"?([a-zA-Z0-9\-_]+)\"?\s*$/m;
$webutil->error("Missing API ".($apiUser?"Token":"User"), "FRC_API_USER=\"myusername\"\nFRC_API_TOKEN=\"myapitoken\"\n\nneeds to be added to local.conf after registering at\n\nhttps://frc-events.firstinspires.org/services/api/register") if (!$apiToken or !$apiUser);

my $ua = LWP::UserAgent->new;

sub fetch(){
	my ($url) = @_;
	my $req = HTTP::Request->new(
		'GET',$url,["If-Modified-Since"=>""]
	);
	$req->authorization_basic($apiUser, $apiToken);
	my $response = $ua->request($req);
	$webutil->error("Error fetching $url", $response->message()) if ($response->is_error());
	return $response->content;
}

sub write(){
	my ($url, $file) = @_;
	my $content = &fetch($url);
	$webutil->error("Error opening $file for writing", "$!") if (!open my $fh, ">", $file);
	print $fh $content;
	close $fh;
}
&write("https://frc-api.firstinspires.org/v3.0/$eventYear/events?eventCode=$eventId","../data/$event.info.json");
&write("https://frc-api.firstinspires.org/v3.0/$eventYear/schedule/$eventId?tournamentLevel=qualification","../data/$event.schedule.qualification.json");
&write("https://frc-api.firstinspires.org/v3.0/$eventYear/schedule/$eventId?tournamentLevel=playoff","../data/$event.schedule.playoff.json");
&write("https://frc-api.firstinspires.org/v3.0/$eventYear/scores/$eventId/qualification","../data/$event.scores.qualification.json");
&write("https://frc-api.firstinspires.org/v3.0/$eventYear/scores/$eventId/playoff","../data/$event.scores.playoff.json");

$webutil->error("Done");
$webutil->redirect("/event.html#$event");
