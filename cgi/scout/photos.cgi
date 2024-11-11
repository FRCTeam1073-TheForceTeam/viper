#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Data::Dumper;
use File::Temp;
use File::Slurp;
use lib '../../pm';
use webutil;
use db;
use dbimport;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new;
my $dbimport = dbimport->new;

my $season = $cgi->param("season");
$webutil->error("Missing season") if (!$season);
$webutil->error("Unexpected season", $season) if ($season !~ /^20[0-9]{2}(-[0-9]{2})?$/);

my $dbh = $db->dbConnection();
my $dir = "../data/$season/";

if (!$dbh and ! -e $dir){
	mkdir $dir;
}

my $teams = [];

for my $team ($cgi->param){
	if ($team =~ /^[0-9]+$/){
		my $success = 0;
		for my $suffix ("", "-top"){
			my $param = "$team$suffix";
			my $upload_fh = $cgi->upload($param);
			my $info = $cgi->uploadInfo($upload_fh);
			if ($info){
				$webutil->error("Expected image photo upload", $info->{'Content-Type'}) if ($info->{'Content-Type'} !~ /^image\//);
				my $teamPicFile = "../data/$season/$param.jpg";
				if ($dbh){
					$teamPicFile = File::Temp->new(TEMPLATE => 'viperXXXXXXX', SUFFIX => '.jpg', TMPDIR => 1, OPEN => 0)->filename;
				}
				my $upload_file = $cgi->tmpFileName(scalar $cgi->param($param));
				`convert "$upload_file" -auto-orient -resize 1000x1000 "$teamPicFile"`;
				if ($dbh){
					$dbimport->importImageFile("$season/$param.jpg", scalar(read_file($teamPicFile, {binmode=>':raw'})));
				}
				$success = 1;
			}
		}
		push(@$teams, $team) if ($success);
	}
}

$webutil->redirect("/bot-photos.html#season=$season&teams=".join(",",@$teams));
