#!/usr/bin/perl

use strict;
use warnings;

# get the list of CSV event files
my $data = `ls -1 /var/www/html/csv/*.txt`;
my @lines = split /\n/, $data;
my @tmpev;
foreach my $line (@lines) {
    my @items = split /\//, $line;
    next unless (@items > 4);
    my $e = substr $items[-1], 0, -4;
    push @tmpev, $e;
}
my @events = sort @tmpev;



# print web page beginning
print "Content-type: text/html

<!DOCTYPE html>
<html lang=\"en\">
    <head>
    <meta charset=\"utf-8\"/>
    <title>FRC Scouting App</title>
    </head>
    <body bgcolor=\"#eeeeee\"><center>\n";

if (@events < 1) {
    print "    <H2>There are no events to edit</H2>\n";
    print "</center></body></html>\n";
    exit 0;
}

print "
    <H2><FONT COLOR=RED>WARNING: do not edit files while scouting is occurring!<BR><BR> Once you click on the link below you will have loaded a copy of the scouting data. If you make changes and save your copy, and scouters have added data to the same scouting file while you had this file loaded, then the new scouting data will get replaced by your copy.</FONT></H2>
    <H2>Select the Event that you want to edit</H2>
    <br>\n";

foreach my $e (@events) {
    print "<H3><a href=\"/cgi-bin/editcsv.cgi?event=$e\">$e</a></H3>\n";
}

print "</center></body></html>\n";
