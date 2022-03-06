#!/usr/bin/perl

use strict;
use warnings;

my $me = "halt.cgi";
my $state = "";
#
# read in given game data
#
my %params;
if (exists $ENV{'QUERY_STRING'}) {
    my @args = split /\&/, $ENV{'QUERY_STRING'};
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
}
$state = $params{'halt'}  if (defined $params{'halt'});


# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";

if ($state eq "active") {
    my $fh;
    if (!open($fh, ">", "/var/www/cgi-bin/matchdata/halt.txt") ) {
	print "<h3>Error opening halt signel file: $!</h3>\n";
	print "<body></html>\n";
	exit 0;
    }
    print $fh "halt\n";
    close($fh);
    
    print "<h3>Halt signal sent, shutting down</h3>\n";
    print "</body></html>\n";
    exit 0;
}

print "<h2>Are you sure you want to Halt this server?</H2>\n";
print "<br><br><br><br>\n";
print "<h2><a href=\"/admin.html\">No</a></h2>\n";
print "<br><br><br><br>\n";
print "<p><a href=\"${me}?halt=active\">Yes</a></p>\n";
print "</body></html>\n";
exit 0;
