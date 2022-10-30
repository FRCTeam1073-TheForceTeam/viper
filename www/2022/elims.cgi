#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $event = $cgi->param('event');
$webutil->error("No event specified") if (!$event);
$webutil->error("Bad event format") if ($event !~ /^20[0-9]{2}[a-zA-Z0-9_\-]+$/);

my $me = "elims.cgi";

# print web page beginning
print "Content-type: text/html; charset=UTF-8\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";
print "<table cellpadding=2 border=0><tr><td>";
print "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td><th>";
print "<h1>Elimination Tournament</h1>\n";
print "</th><td>";
print "<p>&nbsp; &nbsp; &nbsp;<a href=\"/index.cgi\">Home</a></p>\n";
print "</td></tr></table>\n";

#
# Load alliances
#
my $file = "../data/${event}.alliances.csv";
if (! -f $file) {
    print "<h2>Error, file $file does not exist</h2>\n";
    print "</body></html>\n";
    exit 0;
}
my $alliances = [];

if ( open(my $fh, "<", $file) ) {
    <$fh>;
    for my $i (1..8){
        my @alliance = split(/,/, <$fh>);
        shift(@alliance);
        push(@$alliances, [@alliance])
    }
    close $fh;
} else {
    print "<h2>Error, could not open $file: $!</h2>\n";
    print "</body></html>\n";
    exit 0;
}

sub printAlliance {
    my (@all) = (@_);
    foreach my $a (@all) {
        next if ("$a" eq "");
        print "<td><a href=\"team.cgi?event=$event&team=$a\">$a</a></td>";
    }
}

print "<table cellpadding=5 cellspacing=5 border=0>\n";

for my $i (1..8){
    print "<tr><th>Alliance $i</th>";
    &printAlliance(@{$alliances->[$i-1]});
    print "\n</tr><tr>\n";
}

my $sfile = "../data/${event}.semis";
if ( -f "$sfile" ) {

    my @s1;
    my @s2;
    my @s3;
    my @s4;
    if ( open(my $fh, "<", $sfile) ) {
        my $line = <$fh>;
        @s1 = split /-/, $line;
        $line = <$fh>;
        @s2 = split /-/, $line;
        $line = <$fh>;
        @s3 = split /-/, $line;
        $line = <$fh>;
        @s4 = split /-/, $line;
        close $fh;
    } else {
        print "<h2>Error, could not open $sfile: $!</h2>\n";
        print "</body></html>\n";
        exit 0;
    }

    print "<br><br><br><br>\n";
    print "<table cellpadding=5 cellspacing=5 border=0>\n";
    print "<tr><th>Semifinal Alliance 1</th>";
    printAlliance @s1;
    print "\n</tr><tr>\n";
    print "<tr><th>Semifinal Alliance 4</th>";
    printAlliance @s2;
    print "\n</tr><tr>\n";
    print "<tr><th>Semifinal Alliance 2</th>";
    printAlliance @s3;
    print "\n</tr><tr>\n";
    print "<tr><th>Semifinal Alliance 3</th>";
    printAlliance @s4;
    print "\n</tr></table>\n";
    
}
print "</body></html>\n";
