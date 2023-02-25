#!C:/xampp/perl/bin/perl.exe -w

use strict;
use warnings;
use CGI;
use POSIX qw/strftime/;
use lib '../../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $today = strftime("%Y-%m-%d", localtime);
my $csv = $cgi->param('csv');
my $event = $cgi->param('event');
my $name = $event;
$name =~ s/^20[0-9]{2}//g;
$name = $cgi->param('name')||$name;
my $location = $cgi->param('location')||"";
my $start = $cgi->param('start')||$today;
my $end = $cgi->param('end')||$today;

sub escapeCsv(){
    my ($s) = @_;
	$s =~ s/\r\n|\r|\n/⏎/g;
	$s =~ s/"/״/g;
	$s =~ s/,/،/g;
    return $s
}

$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);
$webutil->error("Missing CSV") if (!$csv);
$webutil->error("Malformed name", $name) if ($name !~ /^[\x20-\x7F]*$/);
$webutil->error("Malformed location", $location) if ($location !~ /^[\x20-\x7F]*$/);
$webutil->error("Malformed start", $start) if ($start !~ /^20[0-9]{2}\-[0-9]{2}\-[0-9]{2}$/);
$webutil->error("Malformed end", $end) if ($end !~ /^20[0-9]{2}\-[0-9]{2}\-[0-9]{2}$/);
$name = &escapeCsv($name);
$location = &escapeCsv($location);
$csv =~ s/\r\n|\r/\n/g;
$webutil->error("Malformed CSV", $csv) if (!$csv or $csv !~ /\AMatch,R1,R2,R3,B1,B2,B3\n(?:(?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+(?:,[0-9]+){6}\n)+\Z/g);

my $file = "../data/${event}.schedule.csv";
$webutil->error("Error opening $file for writing", "$!") if (!open my $fh, ">", $file);
print $fh $csv;
close $fh;

$file = "../data/${event}.event.csv";
$webutil->error("Error opening $file for writing", "$!") if (!open $fh, ">", $file);
print $fh "name,location,start,end\n";
print $fh "$name,$location,$start,$end\n";
close $fh;

$webutil->redirect("/event.html#$event");
