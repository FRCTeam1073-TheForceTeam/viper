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

my @a1;
my @a2;
my @a3;
my @a4;
my @a5;
my @a6;
my @a7;
my @a8;

if ( open(my $fh, "<", $file) ) {
    my $line = <$fh>;
    @a1 = split /-/, $line;
    $line = <$fh>;
    @a2 = split /-/, $line;
    $line = <$fh>;
    @a3 = split /-/, $line;
    $line = <$fh>;
    @a4 = split /-/, $line;
    $line = <$fh>;
    @a5 = split /-/, $line;
    $line = <$fh>;
    @a6 = split /-/, $line;
    $line = <$fh>;
    @a7 = split /-/, $line;
    $line = <$fh>;
    @a8 = split /-/, $line;
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
print "<tr><th>Alliance 1</th>";
printAlliance @a1;
print "\n</tr><tr>\n";
print "<tr><th>Alliance 2</th>";
printAlliance @a2;
print "\n</tr><tr>\n";
print "<tr><th>Alliance 3</th>";
printAlliance @a3;
print "\n</tr><tr>\n";
print "<tr><th>Alliance 4</th>";
printAlliance @a4;
print "\n</tr><tr>\n";
print "<tr><th>Alliance 5</th>";
printAlliance @a5;
print "\n</tr><tr>\n";
print "<tr><th>Alliance 6</th>";
printAlliance @a6;
print "\n</tr><tr>\n";
print "<tr><th>Alliance 7</th>";
printAlliance @a7;
print "\n</tr><tr>\n";
print "<tr><th>Alliance 8</th>";
printAlliance @a8;
print "\n</tr></table>\n";

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
