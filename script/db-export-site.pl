#!/usr/bin/perl

use Data::Dumper;
use lib './pm';
use db;

my $db = db->new();
my $dbh = $db->dbConnection();

die "Expect directory as first argument" if (scalar(@ARGV)==0);
my $dir = @ARGV[0];
die "'$dir' does not exist" if (! -e $dir);
die "'$dir' is not a directory" if (! -d $dir);
$dir =~ s/\/+$//g;
my $site = $db->getSite();
my $fh;

my $sth = $dbh->prepare("SELECT `local_js`, `local_css`, `background_image` FROM `sites` WHERE `site`=?");
$sth->execute($db->getSite());
my $data = $sth->fetchall_arrayref();
if (scalar(@$data)){
	if ($data->[0]->[0]){
		die "Error opening $file for writing: $!" if (!open $fh, ">:encoding(UTF-8)", "$dir/local.js");
		print $fh $data->[0]->[0];
		close $fh;
	}
	if ($data->[0]->[1]){
		die "Error opening $file for writing: $!" if (!open $fh, ">:encoding(UTF-8)", "$dir/local.css");
		print $fh $data->[0]->[1];
		close $fh;
	}
	if ($data->[0]->[2]){
		die "Error opening $file for writing: $!" if (!open $fh, ">:raw", "$dir/local.png");
		print $fh $data->[0]->[2];
		close $fh;
	}
}

my $events = [];
my $sth = $dbh->prepare("SELECT DISTINCT `A`.`event` FROM ((SELECT DISTINCT `event` FROM `schedule` WHERE `site`=?) UNION (SELECT `event` FROM `event` WHERE `site`=?)) as `A`");
$sth->execute($db->getSite(),$db->getSite());
my $data = $sth->fetchall_arrayref();
for $row (@$data){
	my $event = $row->[0];
	push(@$events, $event);
}

sub queryToCsv(){
	my ($table, $csv, $site, $event, $orderby) = @_;
	my $query = "SELECT * FROM `$table` WHERE `site`=? and `event`=? ORDER BY $orderby";
	my $sth = $dbh->prepare($query);
	eval {
		$sth->execute($db->getSite(), $event);
		1;
	} or do {
		my $err = $@;
		return if ($err =~ /Table '.*20[0-9]{2}.*' doesn't exist/);
		die "$err$query";
	};
	my $file = "$dir/$event.$csv.csv";
	die "Error opening $file for writing: $!" if (!open $fh, ">:encoding(UTF-8)", $file);
	my $hasContents = $db->writeCsv($sth,$fh);
	close($fh);
	unlink($file) unless ($hasContents);
	print "$file\n" if ($hasContents);

}

for $event (@$events){
	my ($year) = $event =~ /^(20[0-9]{2})/;
	&queryToCsv("event", "event", $site, $event, "'event'");
	&queryToCsv("schedule", "schedule", $site, $event, "'Match'");
	&queryToCsv("alliances", "alliances", $site, $event, "'alliance'");
	&queryToCsv("${year}scouting", "scouting", $site, $event, "'match', 'team' + 0");
	&queryToCsv("${year}pit", "pit", $site, $event, "'team' + 0");
	&queryToCsv("${year}subjective", "subjective", $site, $event, "'team' + 0");
}

my $sth = $dbh->prepare("SELECT `event`, `file`, `json` FROM `apijson` WHERE `site`=?");
$sth->execute($db->getSite());
my $data = $sth->fetchall_arrayref();
for $row (@$data){
	my $event = $row->[0];
	my $file = $row->[1];
	my $json = $row->[2];
	my $file = "$dir/$event.$file.json";
	print "$file\n";
	die "Error opening $file for writing: $!" if (!open $fh, ">:encoding(UTF-8)", $file);
	print $fh $json;
	close $fh;
}

my $sth = $dbh->prepare("SELECT `year`, `team`, `view`, `image` FROM `images` WHERE `site`=?");
$sth->execute($db->getSite());
my $data = $sth->fetchall_arrayref();
for $row (@$data){
	my $year = $row->[0];
	my $team = $row->[1];
	my $view = $row->[2];
	my $image = $row->[3];
	$view = "-".$view if ($view);
	mkdir "$dir/$year" if (! -e "$dir/$year");
	my $file = "$dir/$year/$team$view.jpg";
	print "$file\n";
	die "Error opening $file for writing: $!" if (!open $fh, ">:raw", $file);
	print $fh $image;
	close $fh;
}
