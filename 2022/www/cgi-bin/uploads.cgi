#!/usr/bin/perl -w

use strict;
use warnings;

# File content data is 'posted' to this web page, meaning via STDIN

# print web page
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";
print "<H1>Upload a Match Schedule</H1>\n";
print "<p><a href=\"/index.html\">Home</a></p>\n";

# STDIN 'CONTENT_LENGTH' is passed via ENV
my $filesize = 0;
my @envkeys = keys %ENV;
foreach my $e (@envkeys) {
    if ($e eq "CONTENT_LENGTH") {
	$filesize = $ENV{'CONTENT_LENGTH'};
    }
}
if ($filesize == 0) {
    print "<p>No upload content received</p>\n";
    print "</body></html>\n";
    exit 0;
}

#
# load and parse content, and write match data
#
my $buffer;
read(STDIN, $buffer, $filesize);
$buffer =~ s/\%2F/\//g;
$buffer =~ s/\%22/"/g;
$buffer =~ s/\%3C/\n/g;
my @lines = split /\n/, $buffer;

my %quals;
my @matches;
my $qualnum = "x";
my $teamnum = 1;

foreach my $line (@lines) {
#    print "<p>DEBUG: $line</p>";
    if ($line =~ /\/match\//) {
	# URLs are double-quoted
	my @items = split /"/, $line;
	next unless (@items > 1);
	my @bits = split /\//, $items[1];
	# qualnum includes venue
	$qualnum = $bits[-1];
	push @matches, $qualnum;
	$teamnum = 1;
	next;
    }
    if ($teamnum < 7 && $line =~ /\/team\//) {
	# URLs are double-quoted
	my @items = split /"/, $line;
	next unless (@items > 1);
	my @bits = split /\//, $items[1];
	next unless (@bits > 2);
	my $key = $qualnum . "_" . $teamnum++;
	$quals{$key} = $bits[-2] unless (defined $quals{$key});
    }
}

# compute expected number of match entries and set teams
my %mhash;
foreach my $m (@matches) {
    for (my $i = 1; $i < 7; $i++) {
	my $key = $m . "_" . $i;
	$mhash{$key} = $quals{$key} if (exists $quals{$key});
    }
}

# sort data and extract venue
my @mlist = sort (keys %mhash);
my @dbits = split /_/, $mlist[0];
my $venue = $dbits[0];

my $file = "/var/www/cgi-bin/matchdata/${venue}.dat";
if ( -f "$file" ) {
    # save previous file for debugging
    my $i = 1;
    my $dest = $file . "$i";
    while ( -f "$dest" ) {
	$i++;
	$dest = $file . "$i";
    }
    `mv -f $file $dest`;
}

# write out match file
if (open my $fh, ">", $file) {
    for (my $i = 0; $i < 200; $i++) {
	for (my $t = 1; $t < 7; $t++) {
	    my $key = $venue . "_qm" . "$i" . "_" . "$t";
	    print $fh "$key = $quals{$key}\n" if (defined $quals{$key});
	}
    }
#    foreach my $m (@mlist) {
#	print $fh "$m = $quals{$m}\n";
#    }
    close $fh;
    print "<p>Match data for $venue successfully stored</p>\n";
} else {
    print "<p>Error opening $file</p>\n";

}
print "</body>\n";
print "</html>\n";
