#!/usr/bin/perl

use open ':std', ':encoding(UTF-8)';
use Data::Dumper;
use File::Slurp;
use lib './pm';
use db;
use csv;

$db = db->new();

for my $file (@ARGV){
	print "FILE: $file\n";
	my ($year, $event, $table) = $file =~ /^(?:.*\/)?(20[0-9]+)([^\.]+)\.([^\.]+)\.csv$/;
	$table = "$year$table" if ($table =~ /^scouting|pit$/);
	$event = "$year$event";
	my $csv = csv->new(scalar(read_file($file, {binmode=>':encoding(UTF-8)'})));

	for my $row (1..$csv->getRowCount()){
		my $data = $csv->getRowMap($row);
		$data->{'event'}=$event;
		eval {
			$db->upsert($table, $data);
			1;
		} or do {
			my $error = $@;
			$row+=1;
			print "Failed on row: $row\n";
			print Dumper($data);
			die $error;
		}
	}
	$db->commit();
}
