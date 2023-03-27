#!/usr/bin/perl -w

# Displays a list of files associated with a particular event

use strict;
use warnings;
use File::Slurp;
use CGI;
use lib '../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;

my $event = $cgi->param('event');

$webutil->error("No event specified") if (!$event);
$webutil->error("Bad event format") if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
my $year = $event;
$year =~ s/^(20[0-9]{2}).*/$1/g;

# print web page beginning
print "Content-type: text/csv; charset=UTF-8\n\n";

# get all of the event files containing match schedules
foreach my $name (glob("data/$event.*")){
	print "/$name\n"
}

if ( -e "data/$event.schedule.csv" ){
	my $contents = read_file("data/$event.schedule.csv");
	my @teams = sort { $a <=> $b } keys(%{{map { $_ => 1 } ($contents =~ /[0-9]+/g)}});

	for my $team (@teams){
		if ( -e "data/$year/$team.jpg"){
			print "data/$year/$team.jpg\n";
		}
		if ( -e "data/$year/$team-top.jpg"){
			print "data/$year/$team-top.jpg\n";
		}
	}
}
