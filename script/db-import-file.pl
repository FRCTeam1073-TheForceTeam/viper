#!/usr/bin/perl

use open ':std', ':encoding(UTF-8)';
use Data::Dumper;
use File::Slurp;
use lib './pm';
use dbimport;

my $dbimport = dbimport->new();

for my $file (@ARGV){
	print "FILE: $file\n";
	$dbimport->importCsvFile($file, scalar(read_file($file, {binmode=>':encoding(UTF-8)'}))) if ($file =~ /\.csv$/);
	$dbimport->importJsonFile($file, scalar(read_file($file, {binmode=>':encoding(UTF-8)'}))) if ($file =~ /\.json$/);
	$dbimport->importImageFile($file, scalar(read_file($file, {binmode=>':raw'}))) if ($file =~ /\.jpg$/);
}
