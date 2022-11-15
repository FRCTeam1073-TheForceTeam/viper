#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;

my $event = $cgi->param('event');
$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9_\-]+$/);

my $alliancesCsv = $cgi->param('alliancesCsv');
$webutil->error("Missing alliances CSV") if (!$alliancesCsv);
$alliancesCsv =~ s/\r\n|\r/\n/g;
$webutil->error("Malformed alliances CSV", $alliancesCsv) if (!$alliancesCsv or $alliancesCsv !~ /\AAlliance,Captain,First Pick,Second Pick,Won Quarter-Finals,Won Semi-Finals,Won Finals\n(?:[0-9]+(?:,[0-9]+){3}(,[01]?){3}\n){8}\Z/g);
my $fileName = "../data/${event}.alliances.csv";
$webutil->error("Error opening $fileName for writing", "$!") if (!open my $fh, ">", $fileName);
print $fh $alliancesCsv;
close $fh;

sub addPlayoffs(){
	my ($csv, $round) = @_;
	$csv =~ s/\r\n|\r/\n/g;
	$webutil->error("Malformed $round playoffs CSV", $csv) if (!$csv or $csv !~ /\AMatch,R1,R2,R3,B1,B2,B3\n(?:$round[0-9]+(?:,[0-9]+){6}\n)+\Z/g);
	$fileName = "../data/${event}.schedule.csv";
	if (! -f $fileName){
		`touch $fileName`;
	}
	open $fh, '+<', $fileName or $webutil->error("Cannot open $fileName", "$!\n");
	flock($fh, LOCK_EX) or $webutil->error("Cannot lock $fileName", "$!\n");
	$/ = undef;
	my $schedule = <$fh>;
	if (!$schedule){
		$schedule = $csv;
	} else {
		$csv =~ s/^Match.*\n//g;
		if ($schedule =~ /^$round/gm){
			$schedule =~ s/(^$round.*\n)+/$csv/gm;
		} else {
			$schedule .= $csv;
		}
	}
	seek $fh, 0, 0;
	truncate $fh, 0;
	print $fh $schedule;
	close $fh;
}

my $quarterFinalsCsv = $cgi->param('quarterFinalsCsv');
&addPlayoffs($quarterFinalsCsv, 'qf') if ($quarterFinalsCsv);

my $semiFinalsCsv = $cgi->param('semiFinalsCsv');
&addPlayoffs($semiFinalsCsv, 'sf') if ($semiFinalsCsv);

my $finalsCsv = $cgi->param('finalsCsv');
&addPlayoffs($finalsCsv, 'f') if ($finalsCsv);

$webutil->redirect("/event.html#$event");
