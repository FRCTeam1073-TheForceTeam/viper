#!/usr/bin/perl -w

use strict;
use warnings;

use Fcntl qw(:flock SEEK_END);


#
# read in previous game state
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

if (exists $ENV{'CONTENT_LENGTH'}) {
    my $content = $ENV{'CONTENT_LENGTH'};
    if ($content > 0) {
	my $data = <STDIN>;
	my @args = split /\&/, $data;
	foreach my $arg (@args) {
	    my @bits = split /=/, $arg;
	    next unless (@bits == 2);
	    $params{$bits[0]} = $bits[1];
	}
    }
}

# prepare the webpage
print "Content-type: text/html


<html>
<head>
<title>FRC Scouting App</title>
</head>
<body bgcolor=\"#dddddd\"><center>\n";

if (! exists $params{'event'}) {
    print "<H2>Error, missing event</H2>\n";
    print "</center></body></html>\n";
    exit 0;
}

#my @pkeys = sort (keys %params);
#foreach my $k (@pkeys) {
#    print "<p>DEBUG: $k = $params{$k}</p>\n";
#}

sub cleanText {
    my ($str) = (@_);

    $str =~ s/%0A//g;
    $str =~ s/%0D//g;
    $str =~ s/\+/ /g;

    return $str;
}

my $event = $params{'event'};
my $file = "/var/www/html/csv/" . $event . ".txt";

my $maxrows = `cat $file | wc -l`;
chomp $maxrows;

my $content = "";
# create the file from the %params
my $exists = 1;
my $printed = 0;
for (my $r = 1; $exists != 0; $r++) {
    for (my $c = 1; $exists != 0; $c++) {
	my $key = "r${r}c${c}";
	if (! exists $params{$key}) {
	    # if no first entry then we must be at the end
	    # else we just hit the end of this row
	    # if we are past $maxrows then we're done
	    $exists = 0 if ($r > $maxrows);
	    last;
	}
	# check for row deletion
	last if ($r > 1 && $c == 1 && "$params{$key}" ne "$event");
	# print content
	$content .= "," if ($c != 1);
	$content .= cleanText($params{$key});
	$printed = 1;
    }
    $content .= "\n" unless ($exists == 0 || $printed == 0);
    $printed = 0;
}

my $errstr = "";

# save a copy of the file first
my $copy = "${file}-orig";
if (-f $copy) {
    my $count = 1;
    my $newfile = "${copy}${count}";
    while (-f "$newfile") {
	$count++;
	$newfile = "${copy}${count}";
    }
    $copy = $newfile;
}
`cp -f $file $copy`;

if (open my $fh, '>', $file) {
    if (flock ($fh, LOCK_EX)) {
	print $fh "$content";
    } else {
	$errstr = "failed to lock $file: $!\n";
    }
    flock ($fh, LOCK_UN);
    close $fh;
} else {
    $errstr = "failed to open $file: $!\n";
}

if ("$errstr" ne "") {
    print "<H2>Error: $errstr</H2>\n";
    print "</center></body></html>\n";
    exit 0;
}

print "<H2>File for event $event successfully updated</H2>\n";
print "<h2>Click <a href=\"/admin.html\">here</a> to return to the Admin page</H2>\n";
print "</center></body></html>\n";
