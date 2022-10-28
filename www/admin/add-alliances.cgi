#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $alliancesCsv = $cgi->param('alliancesCsv');
my $quarterFinalsCsv = $cgi->param('quarterFinalsCsv');
my $event = $cgi->param('event');

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9_\-]+$/);
$webutil->error("Missing alliances CSV") if (!$alliancesCsv);
$alliancesCsv =~ s/\r\n|\r/\n/g;
$webutil->error("Malformed alliances CSV", $alliancesCsv) if (!$alliancesCsv or $alliancesCsv !~ /\AAlliance,Captain,First Pick,Second Pick\n(?:[0-9]+(?:,[0-9]+){3}\n){8}\Z/g);
$webutil->error("Missing quarter finals CSV") if (!$quarterFinalsCsv);
$quarterFinalsCsv =~ s/\r\n|\r/\n/g;
$webutil->error("Malformed quarter finals CSV", $quarterFinalsCsv) if (!$quarterFinalsCsv or $quarterFinalsCsv !~ /\AMatch,R1,R2,R3,B1,B2,B3\n(?:qf[0-9]+(?:,[0-9]+){6}\n){12}\Z/g);

my $fileName = "../data/${event}.alliances.csv";
$webutil->error("Error opening $fileName for writing", "$!") if (!open my $fh, ">", $fileName);
print $fh $alliancesCsv;
close $fh;

$fileName = "../data/${event}.schedule.csv";
if (! -f $fileName){
    `touch $fileName`;
}
open $fh, '+<', $fileName or $webutil->error("Cannot open $fileName", "$!\n");
flock($fh, LOCK_EX) or $webutil->error("Cannot lock $fileName", "$!\n");
$/ = undef;
my $schedule = <$fh>;
if (!$schedule){
    $schedule = $quarterFinalsCsv;
} else {
    $quarterFinalsCsv =~ s/^Match.*\n//g;
    if ($schedule =~ /^qf/gm){
        $schedule =~ s/(^qf.*\n)+/$quarterFinalsCsv/gm;
    } else {
        $schedule .= $quarterFinalsCsv;
    }
}
seek $fh, 0, 0;
truncate $fh, 0;
print $fh $schedule;
close $fh;

$webutil->redirect("/event.html#$event");
