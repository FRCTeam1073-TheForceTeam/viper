#!/usr/bin/perl

use strict;

use Data::Dumper;

my $total = 0;
my $scouters = {};

for my $file (@ARGV){
	print "$file\n";
	for my $line (split(/\n/, `cat $file`)){
		if ($line =~ /^ *([0-9]+) (.*)/){
			my $scouter = $2;
			my $count = int($1);
			$scouters->{$scouter} = 0 if (not $scouters->{$scouter});
			$scouters->{$scouter} = $count + $scouters->{$scouter};
			$total += $count;
		}
	}
	
	print "Total: $total\n";
	for my $scouter (sort {$scouters->{$b} - $scouters->{$a}} keys %$scouters){
		print "$scouters->{$scouter}\t$scouter\n";
	}
}