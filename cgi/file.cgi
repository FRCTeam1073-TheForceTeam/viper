#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use YAML;
use CGI qw(-utf8);;
use lib '../pm';
use webutil;
use db;


my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new();

my $file = $cgi->param('file');
$webutil->error("No file specified") if (!$file);
if ($file =~ /\.csv$/){
	&csv($file);
} elsif ($file =~ /\.json$/){
	&json($file);
} elsif ($file =~ /\.jpg$/){
	&image($file);
} else {
	$webutil->notfound();
}

sub json(){
	my ($file) = @_;
	$webutil->error("Unexpected file name", $file) if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-]+\..*\.json$/);
	my ($event, $name) = $file =~ /^(20[0-9]+[^\.]+)\.(.*)\.json$/;
	my $dbh = $db->dbConnection();
	my $sth = $dbh->prepare("SELECT `json` FROM `apijson` WHERE `site`=? AND `event`=? AND `file`=?");
	$sth->execute($db->getSite(), $event, $name);
	my $data = $sth->fetchall_arrayref();

	$webutil->notfound() if (!scalar(@$data));

	binmode(STDOUT, ":utf8");
	print "Cache-Control: max-age=10, stale-if-error=28800, public, must-revalidate\n";
	print "Content-type: text/json; charset=UTF-8\n\n";
	print $data->[0]->[0];
}

sub image(){
	my ($file) = @_;
	$webutil->error("Unexpected file name", $file) if ($file !~ /^20[0-9]{2}\/[0-9]+(?:\-[a-z]+)?\.jpg$/);
	my ($year, $team, $view) = $file =~ /^(20[0-9]{2})\/([0-9]+)(?:\-([a-z]+))?\.jpg$/;
	$view = $view||"";
	my $dbh = $db->dbConnection();
	my $sth = $dbh->prepare("SELECT `image` FROM `images` WHERE `site`=? AND `year`=? AND `team`=? AND `view`=?");
	$sth->execute($db->getSite(), $year, $team, $view);
	my $data = $sth->fetchall_arrayref();
	$webutil->notfound() if (!scalar(@$data));

	binmode(STDOUT, ":raw");
	print "Cache-Control: max-age=10, stale-if-error=28800, public, must-revalidate\n";
	print "Content-type: image/jpg\n\n";
	print $data->[0]->[0];
}

sub csv(){
	my ($file) = @_;
	$webutil->error("Unexpected file name", $file) if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-]+\.(scouting|pit|event|schedule|alliances)\.csv$/);

	my ($year, $event, $table) = $file =~ /^(20[0-9]+)([^\.]+)\.([^\.]+)\.csv$/;

	my $combined = ($event eq 'combined') and ($table eq 'scouting');
	$table = "$year$table" if ($table =~ /^scouting|pit$/);
	$event = "$year$event";

	my $dbh = $db->dbConnection();
	my $sth;
	if ($combined){
		$sth = $dbh->prepare("SELECT * FROM `$table` WHERE `site`=? AND `event` LIKE '$year%'");
	} else {
		$sth = $dbh->prepare("SELECT * FROM `$table` WHERE `site`=? AND `event`='$event'");
	}
	$sth->execute($db->getSite());
	$db->printCsv($sth)
}
