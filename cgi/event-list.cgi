#!/usr/bin/perl -w

# Displays a list of events in CSV

use strict;
use warnings;
use Data::Dumper;
use open ':std', ':encoding(UTF-8)';
use File::Slurp;
use lib '../pm';
use db;
use webutil;

binmode(STDOUT, ":utf8");

my $db = db->new();
my $webutil = webutil->new;

sub isoDate(){
	my ($time) = @_;
	my ($sec, $min, $hour, $mday, $mon, $year) = localtime($time);
	$year+=1900;
	$mon+=1;
	$mday="$mday";
	$mon="$mon";
	$mday="0$mday" if(length($mday)==1);
	$mon="0$mon" if(length($mon)==1);
	return "$year-$mon-$mday";
}

# print web page beginning
print "Cache-Control: max-age=10, stale-if-error=28800, public, must-revalidate\n";
print "Content-type: text/csv; charset=UTF-8\n\n";

my $dbh = $db->dbConnection();
if ($dbh){
	my $sth = $dbh->prepare("SELECT * FROM `event` WHERE `site`=?");
	$sth->execute($db->getSite());
	$db->writeCsv($sth, \*STDOUT, 0, 1);
	exit 0;
}

# get all of the event files containing match schedules
foreach my $name (glob("data/*.schedule.csv")){
	$name =~ s/\..*//g; # Remove file extension
	$name =~ s/.*\///g; # Remove directory
	print "$name";
	my $eventFile =  "data/$name.event.csv";
	if (-e $eventFile){
		print ",";
		my $data = read_file($eventFile, {binmode=>':encoding(UTF-8)'});
		$data =~ s/^\A.*[\r\n]+//g; # Remove header line
		chomp $data;
		print $data;
	} else {
		my $mod = &isoDate((stat("data/$name.schedule.csv"))[9]);
		print ",,,,$mod,$mod";
	}
	print "\n";
}
