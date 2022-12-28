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
                my $teamPicFile = "../data/$year/$param.jpg";
                my $upload_file = $cgi->tmpFileName(scalar $cgi->param($param));
                `convert "$upload_file" -resize 1000x1000 "$teamPicFile"`;
                $success = 1;
            }
        }
        push(@$teams, $team) if ($success);
    }
}

$webutil->redirect("/bot-photos.html#".join(",",@$teams));
