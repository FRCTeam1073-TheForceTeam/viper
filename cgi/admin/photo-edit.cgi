#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $file = $cgi->param('file');
my $rotateClockwise = $cgi->param('rotate-clockwise');
my $rotateCounterClockwise = $cgi->param('rotate-counter-clockwise');
my $delete = $cgi->param('delete');

$webutil->error("Missing file name") if (!$file);
$webutil->error("Malformed file name", $file) if ($file !~ /^20[0-9]{2}\/[0-9]+(\-[a-z]+)?\.jpg$/);
my $filePath = "../data/${file}";

if ($delete){
	unlink $filePath;
}

if ($rotateClockwise){
	my $out=`jpegtran -rotate 90 -trim -outfile "$filePath" "$filePath"`;
}

if ($rotateCounterClockwise){
	my $out=`jpegtran -rotate 270 -trim -outfile "$filePath" "$filePath"`;
}

$webutil->redirect("/photo-edit.html#$file");
