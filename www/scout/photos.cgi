#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Data::Dumper;
use lib '../../pm';
use webutil;


my $cgi = CGI->new;
my $webutil = webutil->new;

my $year = $cgi->param("year");
$webutil->error("Missing year") if (!$year);
$webutil->error("Unexpected year", $year) if ($year !~ /^20[0-9]{2}$/);

`mkdir -p ../data/$year/`;

my $teams = ();

for my $team ($cgi->param){
    if ($team =~ /^[0-9]+$/){
        my $upload_fh = $cgi->upload($team);
        my $info = $cgi->uploadInfo($upload_fh);
        if ($info){
            $webutil->error("Expected image photo upload", $info->{'Content-Type'}) if ($info->{'Content-Type'} !~ /^image\//);
            my $teamPicFile = "../data/$year/$team.jpg";
            my $upload_file = $cgi->tmpFileName(scalar $cgi->param($team));
            `convert "$upload_file" -resize 1000x1000 "$teamPicFile"`;
            push(@$teams, $team)
        }
    }
}

$webutil->redirect("/bot-photos.html#".join(",",@$teams));
