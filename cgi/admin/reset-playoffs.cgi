#!/usr/bin/perl -w

# Admin action: reset an event's playoff bracket by clearing the alliances and
# every generated playoff match, so alliances can be re-entered from scratch.
# Qualification/practice matches are left untouched.

use strict;
use warnings;
use CGI;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use webutil;
use db;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new();

my $event = $cgi->param('event');
$webutil->error("Missing event ID") if (!$event);
$webutil->error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9\-]+$/);

sub clearFile {
	my ($file, $transform) = @_;
	return if (! -f $file);
	my $lockFile = "$file.lock";
	open(my $lock, '>', $lockFile) or $webutil->error("Cannot open $lockFile", "$!\n");
	flock($lock, LOCK_EX) or $webutil->error("Cannot lock $lockFile", "$!\n");
	open(my $fh, "+<", $file) or $webutil->error("Cannot open $file", "$!\n");
	local $/ = undef;
	my $content = <$fh>;
	$content = $transform->($content // "");
	seek $fh, 0, 0;
	truncate $fh, 0;
	print $fh $content;
	close $fh;
	$webutil->commitDataFile($file, "reset playoffs");
	close $lock;
	unlink($lockFile);
}

my $dbh = $db->dbConnection();
if ($dbh){
	$db->deleteAlliances($event);
	$db->deletePlayoffSchedule($event);
	$db->commit();
} else {
	# Empty the alliances file (an empty CSV reads back as no alliances).
	clearFile("../data/$event.alliances.csv", sub { return "" });
	# Strip every playoff match from the schedule, keeping qualification/practice rows.
	clearFile("../data/$event.schedule.csv", sub {
		my ($s) = @_;
		$s =~ s/^(?:f|sf|qf|[1-5]p)[0-9].*\n//gm;
		return $s;
	});
}

$webutil->redirect("/playoffs.html#$event");
