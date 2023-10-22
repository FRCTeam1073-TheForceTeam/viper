#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use webutil;
use db;
use csv;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new();

my $event = $cgi->param('event');
$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);

my $alliancesCsv = $cgi->param('alliancesCsv');
$webutil->error("Missing alliances CSV") if (!$alliancesCsv);
$alliancesCsv =~ s/\r\n|\r/\n/g;
$alliancesCsv =~ s/,undefined/,/g;
$webutil->error("Malformed alliances CSV", $alliancesCsv) if (!$alliancesCsv or $alliancesCsv !~ /\AAlliance,Captain,First Pick,Second Pick,(?:(?:Won Quarter-Finals,Won Semi-Finals)|(?:Won Playoffs Round 1,Won Playoffs Round 2,Won Playoffs Round 3,Won Playoffs Round 4,Won Playoffs Round 5)),Won Finals\n(?:[0-9]+(?:,[0-9]+){3}(,[01]?){3,6}\n){8}\Z/g);

my $newSchedule = $cgi->param('scheduleCsv');
if ($newSchedule){
	$newSchedule =~ s/\r\n|\r/\n/g;
	$webutil->error("Malformed playoffs CSV", $newSchedule) if ($newSchedule !~ /\AMatch,R1,R2,R3,B1,B2,B3\n(?:(?:f|sf|qf|1p|2p|3p|4p|5p)[0-9]+(?:,[0-9]+){6}\n)+\Z/g);
	$newSchedule =~ //g;
}

my $dbh = $db->dbConnection();

sub writeCsvData(){
	my $fileName = "../data/${event}.alliances.csv";
	my $lockFile = "$fileName.lock";
	open(my $lock, '>', $lockFile) or $webutil->error("Cannot open $lockFile", "$!\n");
	flock($lock, LOCK_EX) or $webutil->error("Cannot lock $lockFile", "$!\n");
	$webutil->error("Error opening $fileName for writing", "$!") if (!open my $fh, ">", $fileName);
	print $fh $alliancesCsv;
	close $fh;
	$webutil->commitDataFile($fileName, "playoffs");

	if ($newSchedule){
		my $rounds = join("|", do { my %seen; grep { !$seen{$_}++ } $newSchedule =~ /^(f|sf|qf|1p|2p|3p|4p|5p)/gm});
		$fileName = "../data/${event}.schedule.csv";
		if (! -f $fileName){
			open my $fc, ">", $fileName or $webutil->error("Cannot create $fileName", "$!\n");
			close $fc;
		}
		open $fh, "+<", $fileName or $webutil->error("Cannot open $fileName", "$!\n");
		flock($fh, LOCK_EX) or $webutil->error("Cannot lock $fileName", "$!\n");
		$/ = undef;
		my $schedule = <$fh>;
		if (!$schedule){
			$schedule = $newSchedule;
		} else {
			$newSchedule =~ s/^Match.*\n//g;
			if ($schedule =~ /^($rounds)/gm){
				$schedule =~ s/(^($rounds).*\n)+/$newSchedule/gm;
			} else {
				$schedule .= $newSchedule;
			}
		}
		seek $fh, 0, 0;
		truncate $fh, 0;
		print $fh $schedule;
		close $fh;
		$webutil->commitDataFile($fileName, "playoffs");
		close $lock;
		unlink($lockFile);
	}
}

sub writeDbData(){
	my $csv = csv->new($alliancesCsv);
	for my $row (1..$csv->getRowCount()){
		my $data = $csv->getRowMap($row);
		$data->{'event'}=$event;
		$db->upsert('alliances', $data);
	}

	if ($newSchedule){
		$csv = csv->new($newSchedule);
		for my $row (1..$csv->getRowCount()){
			my $data = $csv->getRowMap($row);
			$data->{'event'}=$event;
			$db->upsert('schedule', $data);
		}
	}
	$db->commit();
}

if ($dbh){
	&writeDbData();
} else {
	&writeCsvData();
}

$webutil->redirect("/event.html#$event");
