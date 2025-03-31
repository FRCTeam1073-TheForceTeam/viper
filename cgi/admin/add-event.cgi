#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use File::Slurp;
use Data::Dumper;
use POSIX qw/strftime/;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use webutil;
use csv;
use db;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new();

my $today = strftime("%Y-%m-%d", localtime);
my $schedule = $cgi->param('csv')||"";
my $event = $cgi->param('event');
my $name = $event;
$name =~ s/^20[0-9]{2}(-[0-9]{2})?//g;
$name = $cgi->param('name')||$name;
my $location = $cgi->param('location')||"";
my $start = $cgi->param('start')||$today;
my $end = $cgi->param('end')||$today;
my $comp = "frc";
$comp = "ftc" if ($event =~ /^20[0-9]{2}-[0-9]{2}/);

sub escapeCsv(){
	my ($s) = @_;
	$s =~ s/\r\n|\r|\n/⏎/g;
	$s =~ s/"/״/g;
	$s =~ s/,/،/g;
	return $s
}

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$webutil->error("Malformed start", $start) if ($start !~ /^20[0-9]{2}\-[0-9]{2}\-[0-9]{2}$/);
$webutil->error("Malformed end", $end) if ($end !~ /^20[0-9]{2}\-[0-9]{2}\-[0-9]{2}$/);
$name = &escapeCsv($name);
$location = &escapeCsv($location);
$schedule =~ s/\r\n|\r/\n/g;
$webutil->error("Malformed FRC CSV", $schedule) if ($comp eq 'frc' && $schedule !~ /\A(Match,R1,R2,R3,B1,B2,B3\n(?:(?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+(?:,[0-9]+){6}\n)+)?\Z/g);
$webutil->error("Malformed FTC CSV", $schedule) if ($comp eq 'ftc' && $schedule !~ /\A(Match,R1,R2,B1,B2\n(?:(?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+(?:,[0-9]+){4}\n)+)?\Z/g);

my $dbh = $db->dbConnection();

sub writeCsvData(){
	my ($file, $lockFile, $lock, $fh);
	if ($schedule){
		$file = "../data/${event}.schedule.csv";
		$lockFile = "$file.lock";
		open($lock, '>', $lockFile) or $webutil->error("Cannot open $lockFile", "$!\n");
		flock($lock, LOCK_EX) or $webutil->error("Cannot lock $lockFile", "$!\n");
		if ( -e $file){
			my $oldSchedule = read_file($file, {binmode => ':encoding(UTF-8)'});
			my ($oldPractice) = $oldSchedule =~ /((?:^pm.*\n)+)/m;
			my ($oldQuals) = $oldSchedule =~ /((?:^qm.*\n)+)/m;
			my ($oldPlayoffs) = $oldSchedule =~ /((?:^(?:qf|sf|(?:[1-5]p)).*\n)+)/m;
			my ($headers) = $schedule =~ /((?:^Match.*\n)+)/m;
			my ($newPractice) = $schedule =~ /((?:^pm.*\n)+)/m;
			my ($newQuals) = $schedule =~ /((?:^qm.*\n)+)/m;
			my ($newPlayoffs) = $schedule =~ /((?:^(?:qf|sf|(?:[1-5]p)).*\n)+)/m;
			$schedule = $headers.($newPractice||$oldPractice||"").($newQuals||$oldQuals||"").($newPlayoffs||$oldPlayoffs||"");
		}
		$webutil->error("Error opening $file for writing", "$!") if (!open $fh, ">", $file);
		print $fh $schedule;
		close $fh;
		$webutil->commitDataFile($file, "add-event");
		close $lock;
		unlink($lockFile);
	}

	$file = "../data/${event}.event.csv";
	$lockFile = "$file.lock";
	open($lock, '>', $lockFile) or $webutil->error("Cannot open $lockFile", "$!\n");
	flock($lock, LOCK_EX) or $webutil->error("Cannot lock $lockFile", "$!\n");
	my $blueAllianceId = $event;
	my $orangeAllianceId = $event;
	my $firstInspiresId = $event;
	$firstInspiresId =~ s/^([0-9]{4})(-[0-9]{2})/$1\//g;
	$orangeAllianceId =~ s/^20([0-9]{2})-([0-9]{2})/$1$2-/g;
	$orangeAllianceId = uc($orangeAllianceId);
	$orangeAllianceId =~ s/-US([A-Z]{2})/-$1-/g;
	if (-e $file){
		my $oldFile = read_file($file, {binmode => ':encoding(UTF-8)'});
		my $oldEvent = csv->new($oldFile);
		$blueAllianceId = $oldEvent->getByName(1,"blue_alliance_id")||$blueAllianceId;
		$orangeAllianceId = $oldEvent->getByName(1,"orange_alliance_id")||$orangeAllianceId;
		$firstInspiresId = $oldEvent->getByName(1,"first_inspires_id")||$firstInspiresId;
	}
	$webutil->error("Error opening $file for writing", "$!") if (!open $fh, ">", $file);
	if ($comp eq 'frc'){
		print $fh "name,location,blue_alliance_id,end,first_inspires_id,start\n";
		print $fh "$name,$location,$blueAllianceId,$end,$firstInspiresId,$start\n";
	} else {
		print $fh "name,location,end,first_inspires_id,orange_alliance_id,start\n";
		print $fh "$name,$location,$end,$firstInspiresId,$orangeAllianceId,$start\n";
	}
	close $fh;
	$webutil->commitDataFile($file, "add-event");
	close $lock;
	unlink($lockFile);
}

sub writeDbData(){
	my $blueAllianceId = $event;
	my $orangeAllianceId = $event;
	my $firstInspiresId = $event;
	$firstInspiresId =~ s/^([0-9]{4})/$1\//g;
	my $sth = $dbh->prepare("SELECT `blue_alliance_id`, `first_inspires_id`, `orange_alliance_id` FROM `event` WHERE `site`=? AND `event`=?");
	$sth->execute($db->getSite(), $event);
	my $data = $sth->fetchall_arrayref();
	if ($data && scalar(@$data)){
		$blueAllianceId = $data->[0]->[0]||$blueAllianceId;
		$firstInspiresId = $data->[0]->[1]||$firstInspiresId;
		$orangeAllianceId = $data->[0]->[2]||$orangeAllianceId;
	}
	if ($schedule){
		if ($schedule =~ /((?:^pm.*\n)+)/m){
			$dbh->prepare("DELETE FROM `schedule` WHERE `site`=? AND `event`=? AND `match` like 'pm%'")->execute($db->getSite(), $event);
		}
		if ($schedule =~ /((?:^qm.*\n)+)/m){
			$dbh->prepare("DELETE FROM `schedule` WHERE `site`=? AND `event`=? AND `match` like 'qm%'")->execute($db->getSite(), $event);
		}
		if ($schedule =~ /((?:^(?:qf|sf|(?:[1-5]p)).*\n)+)/m){
			$dbh->prepare("DELETE FROM `schedule` WHERE `site`=? AND `event`=? AND (`match` like 'qf%' OR `match` like 'sf%' OR `match` like '1p%' OR `match` like '2p%' OR `match` like '3p%' OR `match` like '4p%' OR `match` like '5p%')")->execute($db->getSite(), $event);
		}
		my $csv = csv->new($schedule);
		for my $row (1..$csv->getRowCount()){
			my $data = $csv->getRowMap($row);
			$data->{'event'}=$event;
			$db->upsert('schedule', $data);
		}
	}
	$db->upsert('event', {
		'event' => $event,
		'name'=> $name,
		'location' => $location,
		'start'=> $start,
		'end'=> $end,
		'blue_alliance_id'=> $blueAllianceId,
		'orange_alliance_id'=> $orangeAllianceId,
		'first_inspires_id'=> $firstInspiresId,
	});
	$db->commit();
}

if ($dbh){
	&writeDbData();
} else {
	&writeCsvData();
}

$webutil->redirect("/event.html#$event");
