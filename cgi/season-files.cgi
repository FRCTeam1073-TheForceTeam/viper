#!/usr/bin/perl -w

# Displays a list of files associated with a particular event

use strict;
use warnings;
use File::Slurp;
use CGI;
use Data::Dumper;
use lib '../pm';
use webutil;
use db;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new;

my $season = $cgi->param('season');

$webutil->error("No season specified") if (!$season);
$webutil->error("Bad season format") if ($season !~ /^20[0-9]{2}(-[0-9]{2})?$/);

# print web page beginning
print "Content-type: text/csv; charset=UTF-8\n\n";

# list all of the event files
foreach my $name (glob("$season/*.*")){
	print "/$name\n"
}
