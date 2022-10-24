#!/usr/bin/perl -w

# Displays a list of events in CSV

use strict;
use warnings;

# print web page beginning
print "Content-type: text/csv; charset=UTF-8\n\n";

# get all of the event files containing match schedules
foreach my $name (split /\n/, `ls -1 -r data/*.dat`){
    $name =~ s/\..*//g; # Remove file extension
    $name =~ s/.*\///g; # Remove directory
    print "$name\n"
}