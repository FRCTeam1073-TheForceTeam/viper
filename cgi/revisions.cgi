#!/usr/bin/perl -w

# Displays file history

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use CGI;
use JSON::PP;
use lib '../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;

my $file = $cgi->param('file');
my $revision = $cgi->param('revision');
my $download = $cgi->param('download');

$webutil->error("No file specified") if (!$file);
$webutil->error("Unexpected file name") if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-\.]+\.csv$/);
$webutil->error("Unexpected revision") if ($revision and $revision !~ /^[0-9]+$/);
chdir "data";
$webutil->error("File does not exist") if ( ! -e $file);

if ($revision){
	print "Content-type: text/plain; charset=UTF-8\n";
	print "Content-Disposition: attachment; filename=\"$file\"\n" if ($download);
	print "\n";
	print `src cat "$revision" "$file"`;
	exit;
}

my $log = `src log -u "$file"`;
$log =~ s/\A[^\n]*\n//;
my $entries = [
	map {
		$_ =~ /\A([0-9+]+) *\| ([^ ]+) \| ([^\n]+)\n(.*?)\n\n((?:.|\n)*)\Z/?{
			"revision"=>$1,
			"date"=>$2,
			"branch"=>$3,
			"message"=>$4,
			"diffs"=>$5
		}:{}
	} split(/[\-]{30,}\n/, $log)
];

print "Content-type: application/json; charset=UTF-8\n\n";
print encode_json $entries;
