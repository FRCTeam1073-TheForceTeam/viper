#!/usr/bin/perl

use strict;
use File::Slurp;
use Data::Dumper;
use open ":std", ":encoding(UTF-8)";

my $fileName;

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
	return "!" if ($line =~ /^(?:event,)?(([Mm]atch)|Alliance|team|name),/);
	if ($line =~ /^(?:(20[0-9]{2}[a-z0-9\-]+),)?([0-9]*)(pm|qm|p|qf|sf|f)([0-9]+),([0-9]+)(.*)/){
		my ($event,$roundNum,$roundName,$matchNum,$teamNum,$restOfLine) = ($1,$2,$3,$4,$5,$6);
		$roundNum=substr(("0" x 3).$roundNum, -3);
		$matchNum=substr(("0" x 6).$matchNum, -6);
		$teamNum=substr(("0" x 10).$teamNum, -10);
		$roundName=$RoundNameOrder->{$roundName};
		$event="" if (!$event);
		#print "$event-$roundName-$roundNum-$matchNum-$teamNum\n";
		return "$event-$roundName-$roundNum-$matchNum-$teamNum$restOfLine";
	}
	if ($line =~ /^(?:(20[0-9]{2}[a-z0-9\-]+),)?([0-9]+)(.*)/){
		my ($event,$num1,$restOfLine) = ($1,$2,$3);
		$num1=substr(("0" x 10).$num1, -10);
		$event="" if (!$event);
		#print "$event-$num1\n";
		return "$event-$num1-$restOfLine";
	}
	STDERR->print("Unexpected line format: $line\n") if ($fileName !~ /\.event\.csv$/);
	return "?$line";
}

sub compareLines(){
	return (&lineSortKey($a) cmp &lineSortKey($b))
}

for my $file (@ARGV){
	$fileName = $file;
	my @lines = sort compareLines split(/[\r\n]+/, read_file($file, {binmode=>':encoding(UTF-8)'}));
	open(my $fh, ">:encoding(UTF-8)", $file) or die $!;
	for my $line (@lines){
		print $fh $line,"\n";
	}
	close($fh)
}
