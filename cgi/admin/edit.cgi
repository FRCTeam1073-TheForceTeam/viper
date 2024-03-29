#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use webutil;
use db;
use dbimport;
my $db = db->new;
my $dbimport = dbimport->new;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $csv = $cgi->param('csv');
my $file = $cgi->param('file');
my $delete = $cgi->param('delete');

$webutil->error("Missing file name") if (!$file);
$webutil->error("Malformed file name", $file) if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-]+\.[a-z]+\.csv$/);
my $event = $file;
$event =~ s/\.[a-z]+\.csv$//g;
$file = "../data/${file}";

my $dbh = $db->dbConnection();

if ($delete){
	if ($dbh){
		$dbimport->deleteCsvFile($file, 1);
	} else {
		unlink $file;
	}
	$webutil->redirect("/") if ($file =~ /\.schedule\./);
	$webutil->redirect("/event.html#$event");
} else {
	$csv =~ s/(\r|\n|\r\n)+/\n/g;
	$webutil->error("Missing CSV") if (!$csv);
	if ($dbh){
		$dbimport->importCsvFile($file, $csv);
	} else {
		my $lockFile = "$file.lock";
		open(my $lock, '>', $lockFile) or $webutil->error("Cannot open $lockFile", "$!\n");
		flock($lock, LOCK_EX) or $webutil->error("Cannot lock $lockFile", "$!\n");
		$webutil->error("Error opening $file for writing", "$!") if (!open my $fh, ">", $file);
		print $fh $csv;
		close $fh;
		$webutil->commitDataFile($file, "edit");
		close $lock;
		unlink($lockFile);
	}

	$webutil->redirect("/event.html#$event");
}
