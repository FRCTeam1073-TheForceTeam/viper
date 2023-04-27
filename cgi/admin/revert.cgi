#!/usr/bin/perl -w

# Reverts file

use strict;
use warnings;
use File::Slurp;
use CGI;
use lib '../../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;

my $file = $cgi->param('file');
my $revision = $cgi->param('revision');

$webutil->error("No file specified") if (!$file);
$webutil->error("Unexpected file name") if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-\.]+\.csv$/);
$webutil->error("Unexpected revision") if ($revision and $revision !~ /^[0-9]+$/);
chdir "../data";
$webutil->error("File does not exist") if ( ! -e $file);

my $content = `src cat "$revision" "$file"`;
$webutil->error("Could not get revision content") if ( ! $content);
$webutil->error("Error opening $file for writing", "$!") if (!open my $fh, ">", $file);
print $fh $content;
close $fh;
$webutil->commitDataFile("../data/$file", "revert to revision $revision");
$webutil->redirect("/revisions.html#file=$file");
