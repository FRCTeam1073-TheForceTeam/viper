#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $csv = $cgi->param('csv');
my $event = $cgi->param('event');

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$webutil->error("Missing CSV") if (!$csv);
$csv =~ s/\r\n|\r/\n/g;
$webutil->error("Malformed CSV", $csv) if (!$csv or $csv !~ /\AMatch,R1,R2,R3,B1,B2,B3\n(?:(?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+(?:,[0-9]+){6}\n)+\Z/g);

my $file = "../data/${event}.schedule.csv";
$webutil->error("Error opening $file for writing", "$!") if (!open my $fh, ">", $file);
print $fh $csv;
close $fh;
$webutil->redirect("/event.html#$event");
