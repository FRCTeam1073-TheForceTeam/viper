#!/usr/bin/perl -w

# Displays a list of files associated with a particular event

use strict;
use warnings;
use File::Slurp;
use CGI;
use Data::Dumper;
use lib '../pm';
use webutil;
use db;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new;

my $event = $cgi->param('event');

$webutil->error("No event specified") if (!$event);
$webutil->error("Bad event format") if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
my ($year) = $event =~ /^(20[0-9]{2})/;

# print web page beginning
print "Content-type: text/csv; charset=UTF-8\n\n";

my $dbh = $db->dbConnection();
if ($dbh){
	my $site = $db->getSite();
	my $files = $dbh->selectall_arrayref("
		SELECT '/data/$event.event.csv' AS `file` FROM `event` WHERE `site`='$site' AND `event`='$event'
		UNION SELECT '/data/$event.schedule.csv' AS `file` FROM `schedule` WHERE `site`='$site' AND `event`='$event'
		UNION SELECT '/data/$event.alliances.csv' AS `file` FROM `alliances` WHERE `site`='$site' AND `event`='$event'
		UNION SELECT '/data/$event.pit.csv' AS `file` FROM `${year}pit` WHERE `site`='$site' AND `event`='$event'
		UNION SELECT '/data/$event.subjective.csv' AS `file` FROM `${year}subjective` WHERE `site`='$site' AND `event`='$event'
		UNION SELECT '/data/$event.scouting.csv' AS `file` FROM `${year}scouting` WHERE `site`='$site' AND `event`='$event'
		UNION SELECT CONCAT('/data/$event.',file,'.json') from apijson where `event`='$event'
		UNION SELECT CONCAT('/data/$year/',`img`,'.jpg') AS `file` FROM (
			SELECT DISTINCT CONCAT(`team`,'-',`view`) AS img FROM (
				SELECT DISTINCT `R1` AS `t` FROM `schedule` WHERE `site`='$site' AND `event`='$event'
				UNION SELECT DISTINCT `R2` AS `t` FROM `schedule` WHERE `site`='$site' AND `event`='$event'
				UNION SELECT DISTINCT `R3` AS `t` FROM `schedule` WHERE `site`='$site' AND `event`='$event'
				UNION SELECT DISTINCT `B1` AS `t` FROM `schedule` WHERE `site`='$site' AND `event`='$event'
				UNION SELECT DISTINCT `B2` AS `t` FROM `schedule` WHERE `site`='$site' AND `event`='$event'
				UNION SELECT DISTINCT `B3` AS `t` FROM `schedule` WHERE `site`='$site' AND `event`='$event'
			) AS teams
			JOIN `images` ON teams.t=images.team
			WHERE `site`='$site' AND `year`='$year'

		) AS imgs
		ORDER BY `file`
		;
	");
	for my $file (@$files){
		$file = $file->[0];
		$file =~ s/\-\././g;
		print $file,"\n";
	}
	exit 0;
}

# list all of the event files
foreach my $name (glob("data/$event.*")){
	print "/$name\n"
}

if ( -e "data/$event.schedule.csv" ){
	my $contents = read_file("data/$event.schedule.csv", {binmode=>':encoding(UTF-8)'});
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
