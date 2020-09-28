#!/usr/bin/perl -w

use strict;
use warnings;

if (@ARGV != 1 || ! -f "$ARGV[0]") {
	print "Error, need a file\n";
	exit 1;
}

# extract the venue from the first match link
my $venue = "unknown";

# parse file contents
my $data = `cat $ARGV[0]`;
my @lines = split /\n/, $data;
my %quals;
my @matches;
my $qualnum = "X";
my $teamnum = 1;
foreach my $line (@lines) {
	if ($line =~ /\/match\//) {
		my @items = split /"/, $line;
		next unless (@items > 1);
		my @bits = split /\//, $items[1];
		$qualnum = $bits[-1];
		push @matches, $qualnum;
		$teamnum = 1;
		next;
	}
	if ($teamnum < 7 && $line =~ /\/team\//) {
		my @items = split /"/, $line;
		next unless (@items > 1);
		my @bits = split /\//, $items[1];
		next unless (@bits > 2);
		my $key = $qualnum . "_" . $teamnum++;
		$quals{$key} = $bits[2] unless (defined $quals{$key});
	}
}

#foreach my $k (keys %quals) {
#	print "key $k = $quals{$k}\n";
#}

my %mhash;
foreach my $m (@matches) {
	for(my $i = 1; $i < 7; $i++) {
		my $key = $m . "_" . $i;
		$mhash{$key} = 1;
	}
}
my @mlist = sort (keys %mhash);
$data = $mlist[0];
my @dbits = split /_/, $data;
$venue = $dbits[0];

for (my $i = 0; $i < 200; $i++) {
	for (my $t = 1; $t < 7; $t++) {
		my $key = $venue . "_qm" . $i . "_" . $t; 
		if (defined $quals{$key}) {
			print "$key = $quals{$key}\n";
#		} else {
#			print "missing $key\n";
		}
	}
}

