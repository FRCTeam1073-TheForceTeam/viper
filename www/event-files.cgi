#!/usr/bin/perl -w

# Displays a list of files associated with a particular event

use strict;
use warnings;
use CGI;
use HTML::Escape qw/escape_html/;
use lib '../../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;

my $event = $cgi->param('event');

$webutil->error("No event specified") if (!$event);
$webutil->error("Bad event format") if ($event !~ /^20[0-9]{2}[a-zA-Z0-9_\-]+$/);

# print web page beginning
print "Content-type: text/csv; charset=UTF-8\n\n";

# get all of the event files containing match schedules
foreach my $name (split /\n/, `ls -1 -r data/$event.*`){
    print "/$name\n"
}