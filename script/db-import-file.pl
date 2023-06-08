#!/usr/bin/perl

use open ':std', ':encoding(UTF-8)';
use Data::Dumper;
use File::Slurp;
use lib './pm';
use db;
use csv;

my $db = db->new();

sub importCsvFile(){
	my ($file) = @_;

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

sub importJsonFile(){
	my ($f) = @_;

	my ($event, $fileType) = $f =~ /^(?:.*\/)?(20[0-9]+[^\.]+)\.(.+)\.json$/;
	my $json = scalar(read_file($f, {binmode=>':encoding(UTF-8)'}));

	my $data = {
		'event' => $event,
		'file' => $fileType,
		'json' => $json
	};
	eval {
		$db->upsert('apijson', $data);
		1;
	} or do {
		my $error = $@;
		$row+=1;
		print "Failed on row: $row\n";
		print Dumper($data);
		die $error;
	};
	$db->commit();
}

sub importImageFile(){
	my ($f) = @_;

	my ($year, $team, $view) = $f =~ /^(?:.*\/)?(20[0-9]+)\/([0-9]+)(?:\-([a-z]+))?\.jpg$/;
	my $img = scalar(read_file($f, {binmode=>':raw'}));
	$view = $view||"";

	my $data = {
		'year' => $year,
		'team' => $team,
		'view' => $view,
		'image' => $img
	};
	eval {
		$db->upsert('images', $data);
		1;
	} or do {
		my $error = $@;
		$row+=1;
		print "Failed on row: $row\n";
		$data->{'image'}='---BINARY DATA---';
		print Dumper($data);
		die $error;
	};
	$db->commit();
}

for my $file (@ARGV){
	print "FILE: $file\n";
	&importCsvFile($file) if ($file =~ /\.csv$/);
	&importJsonFile($file) if ($file =~ /\.json$/);
	&importImageFile($file) if ($file =~ /\.jpg$/);
}
