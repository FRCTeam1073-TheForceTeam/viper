#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use CGI qw(-utf8);;
use lib '../pm';
use webutil;
use db;


my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new();

my $file = $cgi->param('file');
$webutil->error("No file specified") if (!$file);
if ($file =~ /local\.js$/){
	&localJs();
} elsif ($file =~ /local\.css$/){
	&localCss($file);
} elsif ($file =~ /(local|background|local\.background)\.png$/){
	&backgroundPng();
} elsif ($file =~ /logo\.png$/){
	&logoPng();
} elsif ($file =~ /\.csv$/){
	&csv($file);
} elsif ($file =~ /\.json$/){
	&json($file);
} elsif ($file =~ /\.jpg$/){
	&image($file);
} else {
	$webutil->notfound();
}

sub localJs(){
	my $dbh = $db->dbConnection();
	my $sth = $dbh->prepare("SELECT `local_js` FROM `sites` WHERE `site`=?");
	$sth->execute($db->getSite());
	my $data = $sth->fetchall_arrayref();

	binmode(STDOUT, ":utf8");
	print "Cache-Control: max-age=28800, public\n";
	print "Content-type: text/js; charset=UTF-8\n\n";
	print $data->[0]->[0] if scalar(@$data);
}

sub localCss(){
	my $dbh = $db->dbConnection();
	my $sth = $dbh->prepare("SELECT `local_css` FROM `sites` WHERE `site`=?");
	$sth->execute($db->getSite());
	my $data = $sth->fetchall_arrayref();

	binmode(STDOUT, ":utf8");
	print "Cache-Control: max-age=28800, public\n";
	print "Content-type: text/css; charset=UTF-8\n\n";
	print $data->[0]->[0] if scalar(@$data);
}


sub backgroundPng(){
	my $dbh = $db->dbConnection();
	my $sth = $dbh->prepare("SELECT `background_image` FROM `sites` WHERE `site`=?");
	$sth->execute($db->getSite());
	my $data = $sth->fetchall_arrayref();
	if (scalar(@$data)){
		$data = $data->[0]->[0];
	} else {
		$data = read_file('background.png', {binmode=>':raw'})
	}
	binmode(STDOUT, ":raw");
	print "Cache-Control: max-age=28800, public\n";
	print "Content-type: image/png\n\n";
	print $data;
}

sub logoPng(){
	my $dbh = $db->dbConnection();
	my $sth = $dbh->prepare("SELECT `logo_image` FROM `sites` WHERE `site`=?");
	$sth->execute($db->getSite());
	my $data = $sth->fetchall_arrayref();
	if (scalar(@$data)){
		$data = $data->[0]->[0];
	} else {
		$data = read_file('background.png', {binmode=>':raw'})
	}

	binmode(STDOUT, ":raw");
	print "Cache-Control: max-age=28800, public\n";
	print "Content-type: image/png\n\n";
	print $data;
}

sub json(){
	my ($file) = @_;
	$webutil->error("Unexpected file name", $file) if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-]*\.[a-z0-9\.]+\.json$/);
	my ($event, $name) = $file =~ /^(20[0-9]+[^\.]*)\.([a-z0-9\.]+)\.json$/;
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

	my $combined = (($event eq 'combined') and ($table eq 'scouting'));
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
	$webutil->notfound() unless $db->printCsv($sth);
}
