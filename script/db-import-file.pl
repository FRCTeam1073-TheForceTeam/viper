#!/usr/bin/perl

use open ':std', ':encoding(UTF-8)';
use Data::Dumper;
use File::Slurp;
use lib './pm';
use dbimport;

my $dbimport = dbimport->new();

for my $file (@ARGV){
	my $site = $dbimport->getSite();
	print "SITE: $site FILE: $file\n";
 	if ($file =~ /local\.js$/){
		$dbimport->importLocalJsFile(scalar(read_file($file, {binmode=>':encoding(UTF-8)'})));
	} elsif ($file =~ /local\.css$/){
		$dbimport->importLocalCssFile(scalar(read_file($file, {binmode=>':encoding(UTF-8)'})));
	} elsif ($file =~ /(local|background|local\.background)\.png$/){
		$dbimport->importLocalBackgroundImageFile(scalar(read_file($file, {binmode=>':raw'})));
	} elsif ($file =~ /(logo|local\.logo)\.png$/){
		$dbimport->importLocalLogoImageFile(scalar(read_file($file, {binmode=>':raw'})));
	} elsif ($file =~ /\.csv$/){
		$dbimport->importCsvFile($file, scalar(read_file($file, {binmode=>':encoding(UTF-8)'})));
	} elsif ($file =~ /\.json$/){
		$dbimport->importJsonFile($file, scalar(read_file($file, {binmode=>':encoding(UTF-8)'})));
	} elsif ($file =~ /\.jpg$/){
		$dbimport->importImageFile($file, scalar(read_file($file, {binmode=>':raw'})));
	} elsif ($file =~ /\*/){
		#ignore wildcard
	} else {
		die "Could not import $file";
	}
}
