#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use JSON::PP;
use MIME::Base64;
use Data::Dumper;
use File::Slurp;
use File::Path 'make_path';
use lib '../../pm';
use webutil;
my $webutil = webutil->new;
my $cgi = CGI->new;
my $json = $cgi->param('json');
$webutil->error("Missing data parameter: json") if (!$json);
my $upload_fh = $cgi->upload('json');
my $info = $cgi->uploadInfo($upload_fh);
if ($info){
	my $upload_file = $cgi->tmpFileName(scalar $json);
	$json = read_file($upload_file)
}
my $data = decode_json($json);
my $event = "";

for my $fileName (keys(%$data)){
	$webutil->error("Unexpected file in data:", $fileName) if ($fileName !~ /^\/data\/20[0-9]{2}((\/[0-9]+[a-z\-]*\.jpg)|([a-z0-9A-Z\-]+\.[a-z]+\.csv))$/);
	$event = $1 if ($fileName =~ /\/data\/(20[0-9]{2}[a-z0-9\-]+)/);
}
$webutil->error("No files files imported have an event name") if (!$event);
for my $fileName (keys(%$data)){
	my $fileContents = $data->{$fileName};
	my $raw = "";
	if ($fileContents =~ /^data:[a-z]+\/[a-z]+;base64,(.*)/){
		$fileContents = decode_base64($1);
		$raw = ":raw"
	}
	$fileName =~ s/^\/data\//..\/data\//g;
	my $dir = $fileName;
	$dir =~ s/[^\/]*$//g;
	make_path($dir);
	$webutil->error("Error opening $fileName for writing", "$!") if (!open my $fh, ">$raw", $fileName);
	print $fh $fileContents;
	close $fh;
}
$webutil->redirect("/event.html#$event");
