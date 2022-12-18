#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $csv = $cgi->param('csv');
my $file = $cgi->param('file');
my $delete = $cgi->param('delete');

$webutil->error("Missing file name") if (!$file);
$webutil->error("Malformed file name", $file) if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-]+\.[a-z]+\.csv$/);
my $event = $file;
$event =~ s/\.[a-z]+\.csv$//g;
$file = "../data/${file}";

if ($delete){
    `rm ${file}`;    
    $webutil->redirect("/") if ($file =~ /\.schedule\./);
    $webutil->redirect("/event.html#$event");
} else {
    $webutil->error("Missing CSV") if (!$csv);
    $webutil->error("Error opening $file for writing", "$!") if (!open my $fh, ">", $file);
    print $fh $csv;
    close $fh;
    $webutil->redirect("/event.html#$event");
}
