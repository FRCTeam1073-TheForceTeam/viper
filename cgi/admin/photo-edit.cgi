#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use File::Slurp;
use File::Temp;
use lib '../../pm';
use webutil;
use db;
use dbimport;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new;
my $dbimport = dbimport->new;

my $file = $cgi->param('file');
my $rotateClockwise = $cgi->param('rotate-clockwise');
my $rotateCounterClockwise = $cgi->param('rotate-counter-clockwise');
my $delete = $cgi->param('delete');
$webutil->error("Missing file name") if (!$file);
$webutil->error("Malformed file name", $file) if ($file !~ /^20[0-9]{2}(-[0-9]{2})?\/[0-9]+(\-[a-z]+)?\.jpg$/);
my $filePath = "../data/${file}";
my $dbh = $db->dbConnection();
my ($year, $team, $view) = $file =~ /^(20[0-9]{2}(?:-[0-9]{2})?)\/([0-9]+)(?:\-([a-z]+))?/;
$view = "" if (!$view);

if ($delete){
	if ($dbh){
		 $dbh->prepare("DELETE FROM `images` WHERE `site`=? AND `year`=? AND `team`=? and `view`=?")->execute($db->getSite(), $year, $team, $view);
		 $db->commit();
	} else {
		unlink $filePath;
	}
	$webutil->redirect("/photo-edit.html?");
} else {
	if ($dbh){
		$filePath = File::Temp->new(TEMPLATE => 'viperXXXXXXX', SUFFIX => '.jpg', TMPDIR => 1)->filename;
		my $sth = $dbh->prepare("SELECT `image` FROM `images` WHERE `site`=? AND `year`=? AND `team`=? AND `view`=?");
		$sth->execute($db->getSite(), $year, $team, $view);
		my $data = $sth->fetchall_arrayref();
		$webutil->notfound() if (!scalar(@$data));
		open my $fh, '>:raw', $filePath or die;
		print $fh $data->[0]->[0];
		close $fh;
	}

	if ($rotateClockwise){
		`jpegtran -rotate 90 -trim -outfile "$filePath" "$filePath"`;
	}

	if ($rotateCounterClockwise){
		`jpegtran -rotate 270 -trim -outfile "$filePath" "$filePath"`;
	}

	if ($dbh){
		$dbimport->importImageFile($file, scalar(read_file($filePath, {binmode=>':raw'})));
	}
	$webutil->redirect("/photo-edit.html#$file");
}
