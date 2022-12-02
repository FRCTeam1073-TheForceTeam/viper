#!/usr/bin/perl -w

use strict;
use warnings;

my $TEAMS = "/var/www/cgi-bin/teams.txt";
my $event = "";

#
# read in given game data
#
if ($ENV{QUERY_STRING}) {
    my @args = split /\&/, $ENV{QUERY_STRING};
    my %params;
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
    $event = $params{'event'} if (defined $params{'event'});
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#ffffff\"><center>\n";

if ($event eq "") {
    print "<H2>Error, need an event</H2>\n";
    print "</body></html>\n";
    exit 0;
}


my $file = "/var/www/cgi-bin/matchdata/${event}.dat";
if (! -f $file) {
    print "<H2>Error, match file ${event}.dat does not exist</H2>\n";
    print "</body></html>\n";
    exit 0;
}


my $fh;
if (! open($fh, "<", $file) ) {
    print "<H2>Error, cannot open ${event}.dat for reading: $!</H2>\n";
    print "</body></html>\n";
    exit 0;
}


my %teamhash;
my %lochash;
while (my $line = <$fh>) {
    my @items = split /\s+/, $line;
    next if (@items != 3);
    my $t = $items[-1];
    $teamhash{$t} = "";
}
close $fh;

# now load the team info
if (! open($fh, "<", $TEAMS) ) {
    print "<h2>Error, cannot open team.txt for reading: $!</H2>\n";
    print "</center></body></html>\n";
    exit 0;
}

while (my $line = <$fh>) {
    my @items = split /:/, $line;
    next unless (@items == 3);
    my $num = $items[0];
    next unless (exists $teamhash{$num});
    $teamhash{$num} = $items[1];
    $lochash{$num} = $items[2];
}

my @teams = sort {$a <=> $b} (keys %teamhash);
print "<table cellspacing=0 cellpadding=0 border=0>";
foreach my $t (@teams) {
    print "<tr><th><FONT size=+2><a href=\"/cgi-bin/team.cgi?event=${event}&team=$t\">$t</a></FONT></th><td>&nbsp;&nbsp;&nbsp;</td>";
    print "<th align=\"left\"><FONT SIZE=+1>$teamhash{$t}</FONT></th><td>&nbsp;&nbsp;&nbsp;</td>";
    print "<th align=\"left\">$lochash{$t}</th></tr>\n";
}
print "</table>\n";

print "</center></body></html>\n";
