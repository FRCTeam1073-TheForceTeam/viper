#!/usr/bin/perl

use strict;
use File::Slurp;
use Data::Dumper;

my $RoundNameOrder = {
	"pm"=>"Apm",
	"qm"=>"Bqm",
	"p"=>"Cp",
	"qf"=>"Dqf",
	"sf"=>"Esf",
	"f"=>"Ff"
};

sub lineSortKey(){
	my ($line) = @_;
	return "!" if ($line =~ /^event,/);
	if ($line =~ /^(20[0-9]{2}[a-z0-9\-]+),([0-9]*)([a-z]+)([0-9]+),([0-9]+)(.*)/){
		my ($event,$roundNum,$roundName,$matchNum,$teamNum,$restOfLine) = ($1,$2,$3,$4,$5,$6);
		$roundNum=substr(("0" x 3).$roundNum, -3);
		$matchNum=substr(("0" x 6).$matchNum, -6);
		$teamNum=substr(("0" x 10).$teamNum, -10);
		$roundName=$RoundNameOrder->{$roundName};
		return "$event-$roundName-$roundNum-$matchNum-$teamNum$restOfLine";
	}
	return "?$line";
}

sub compareLines(){
	return (&lineSortKey($a) cmp &lineSortKey($b))
}

for my $file (@ARGV){
	my @lines = sort compareLines split(/[\r\n]+/, read_file($file));
	open(my $fh, ">", $file) or die $!;
	for my $line (@lines){
		print $fh $line,"\n";
	}
	close($fh)
}
