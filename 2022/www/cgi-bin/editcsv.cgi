#!/usr/bin/perl

use strict;
use warnings;

my $event = "";

#
# read in given game data
#
if ($ENV{'QUERY_STRING'}) {
    my @args = split /\&/, $ENV{'QUERY_STRING'};
    my %params;
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
    $event = $params{'event'}  if (defined $params{'event'});
}

# print web page beginning
print "Content-type: text/html


<!DOCTYPE html>
<html lang=\"en\">
    <head>
    <meta charset=\"utf-8\"/>
    <title>FRC Scouting App</title>
    </head>
    <body bgcolor=\"#eeeeee\"><center>\n";

if ($event eq "") {
    print "<H2>Error, need an event</H2>\n";
    print "</center></body></html>\n";
    exit 0;
}

#
# Load event data
#
my $file = "/var/www/html/csv/${event}.txt";
if (! -f $file) {
    print "<H2>Error, file $file does not exist</H2>\n";
    print "</center></body></html>\n";
    exit 0;
}

my $fh;
if ( ! open($fh, "<", $file) ) {
    print "<H2>Error, could not open $file: $!</H2>\n";
    print "</center></body></html>\n";
    exit 0;
}

print "
    <H2>Edit Scouting Data for $event</H2>
    <p>To delete a complete line, delete the content in the 'event' column for that line</p>
    <form action=\"/cgi-bin/savecsv.cgi\" method=\"post\">
    <input type=\"hidden\" name=\"event\" value=\"$event\">
    <table cellpadding=5 cellspacing=5 border=1>\n";
my $row = 1;
# first number is bogus because col index starts at 1
my @colwidth = ('5');
while (my $line = <$fh>) {
    my @items = split /,/, $line;
    # should at least have 'event','match','team',and one value
    next if (@items < 4);
    my $col = 1;
    print "      <tr>\n";
    if ($row == 1) {
	foreach my $i (@items) {
	    my $size = length $i;
	    push @colwidth, $size;
	    print "        <th>$i\n";
	    print "        <input type=\"hidden\" name=\"r${row}c${col}\" value=\"$i\"></th>\n";
	    $col++;
	}
	print "      </tr>\n";
	$row++;
	next;
    }
    foreach my $i (@items) {
	my $size = length $i;
	$size = $colwidth[$col] if ($colwidth[$col] > $size);
	print "        <td><input type=\"text\" name=\"r${row}c${col}\" size=\"$size\" value=\"$i\"></td>\n";
	$col++;
    }
    print "      </tr>\n";
    $row++;
}

close $fh;

print "    </table>
    <input type=\"image\" src=\"/scoutpics/save_button.png\" width=\"100\" height=\"50\">
    </form>
    </center>
    </body>
    </html>\n";
