#!/usr/bin/perl -w

use strict;
use warnings;
use File::Slurp;
use Data::Dumper;
use YAML;
use CGI qw(-utf8);;
use lib '../pm';
use webutil;
use db;

binmode(STDOUT, ":utf8");

my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new();

my $file = $cgi->param('file');
$webutil->error("No file specified") if (!$file);
$webutil->error("Unexpected file name") if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-]+\.(scouting|pit|event|schedule|alliances)\.csv$/);

my ($year, $event, $table) = $file =~ /^(?:.*\/)?(20[0-9]+)([^\.]+)\.([^\.]+)\.csv$/;
$table = "$year$table" if ($table =~ /^scouting|pit$/);
$event = "$year$event";

my $dbh = $db->dbConnection();
my $sth = $dbh->prepare("SELECT * from `$table` where `event`=?");
$sth->execute($event);
my $columns = $sth->{NAME};
my @withData = map {0} @$columns;
my $data = $sth->fetchall_arrayref();
for my $row (@$data){
	#$webutil->error("row", Dumper($row));
	my $i=0;
	for my $field (@$row){
		@withData[$i] = 1 if ($field);
		$i++;
	}
}

print "Cache-Control: max-age=10, stale-if-error=28800, public, must-revalidate\n";
print "Content-type: text/plain; charset=UTF-8\n\n";
my $i = 0;
my $first = 1;
for my $field (@$columns){
	if ($field ne 'site' and @withData[$i]){
		print (",") if (!$first);
		print("$field");
		$first = 0;
	}
	$i++;
}
print "\n";

for my $row (@$data){
	my $i = 0;
	my $first = 1;
	for my $field (@$row){
		if ($columns->[$i] ne 'site' and @withData[$i]){
			print (",") if (!$first);
			print("$field");
			$first = 0;
		}
		$i++;
	}
	print "\n";
}
