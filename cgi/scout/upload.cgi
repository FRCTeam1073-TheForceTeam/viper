#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Data::Dumper;
use File::Slurp;
use HTML::Escape qw/escape_html/;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use csv;
use webutil;
use db;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $db = db->new();

my $uCsv = $cgi->param('csv');
$webutil->error("No data uploaded", "Scouting CSV data not found.") if (!$uCsv);
$uCsv = [ map { [ split(/,/, $_, -1) ] } split(/[\r\n]+/, $uCsv) ];
$webutil->error("Not enough CSV lines", "expected at least two lines in uploaded CSV") if(scalar(@{$uCsv})<2);
my $csvHeaders;
my $uHead;
my $scoutCsv = {};
my $scoutHeaders = {};
my $pitCsv = {};
my $pitHeaders = {};
my $subjectiveCsv = {};
my $subjectiveHeaders = {};
foreach my $row (@{$uCsv}){
	if ($row->[0] eq 'event'){
		$csvHeaders = $row;
		$uHead = { map { $csvHeaders->[$_] => $_ } 0..(scalar(@{$csvHeaders})-1) };
		foreach my $key (qw(event team)){
			$webutil->error("Missing column", "Expected $key CSV heading") if (! exists $uHead->{$key});
		}
		foreach my $name (@{$csvHeaders}){
			$webutil->error("Unexpected CSV heading",$name) if($name !~ /^[a-zA-Z0-9_\-]+$/);
		}
	} else {
		$webutil->error("Didn't find a header row starting with 'event' before other data") if (!$csvHeaders);
		$webutil->error("Bad row size", "CSV row size (".(scalar @{$row}).") doesn't match heading row size(".(scalar keys %{$uHead}).")\n".join(",",keys %{$uHead})."\n".join(",", @{$row})) if (scalar keys %{$uHead} != scalar @{$row});
		$webutil->error("Unexpected event name",$row->[$uHead->{'event'}]) if($row->[$uHead->{'event'}] !~ /^20\d\d[a-zA-Z0-9\-]+$/);
		$webutil->error("Unexpected team name",$row->[$uHead->{'team'}]) if($row->[$uHead->{'team'}] !~ /^[0-9]+$/);
		my $eventCsv = $pitCsv;
		my $eventHeaders = $pitHeaders;
		if (exists $uHead->{'match'}){
			$webutil->error("Unexpected match name",$row->[$uHead->{'match'}]) if($row->[$uHead->{'match'}] !~ /^[0-9]*[a-z]+[0-9]+$/);
			$eventCsv = $scoutCsv;
			$eventHeaders = $scoutHeaders;
		} elsif (exists $uHead->{'defense_tips'}){
			$eventCsv = $subjectiveCsv;
			$eventHeaders = $subjectiveHeaders;
		}
		$eventCsv->{$row->[$uHead->{'event'}]} = [] if (! exists  $eventCsv->{$row->[$uHead->{'event'}]});
		$eventHeaders->{$row->[$uHead->{'event'}]} = $csvHeaders;
		push(@{$eventCsv->{$row->[$uHead->{'event'}]}}, $row)
	}
}

my $savedKeys = "";
my $dbh = $db->dbConnection();

sub writeCsvData(){
	my ($eventCsv, $eventHeaders, $type) = @_;
	foreach my $event (keys %{$eventCsv}){
		unshift(@{$eventCsv->{$event}}, $eventHeaders->{$event});
		my $newCsv = csv->new($eventCsv->{$event});
		my $fileName = "../data/$event.$type.csv";
		my $lockFile = "$fileName.lock";
		open(my $lock, '>', $lockFile) or $webutil->error("Cannot open $lockFile", "$!\n");
		flock($lock, LOCK_EX) or $webutil->error("Cannot lock $lockFile", "$!\n");
		my $csv = csv->new(-f $fileName?scalar(read_file($fileName, {binmode => ':encoding(UTF-8)'})):"");
		$csv->append($newCsv);
		open my $fh, '>:encoding(UTF-8)', $fileName or $webutil->error("Cannot open $fileName", "$!\n");
		$fh->print($csv->toString());
		close $fh;
		$webutil->commitDataFile($fileName, "scouting");
		close $lock;
		unlink($lockFile);
		foreach my $row (1..$newCsv->getRowCount()){
			&appendSavedKey($type, $event, $newCsv->getByName($row,"match"), $newCsv->getByName($row,"team"));
		}
	}
}

sub appendSavedKey(){
	my ($type, $event, $match, $team) = @_;
	$savedKeys .= "," if($savedKeys);
	if ($type eq 'scouting'){
		$savedKeys .= "${event}_${match}_${team}";
	} elsif ($type eq 'pit'){
		$savedKeys .= "${event}_${team}";
	} elsif ($type eq 'subjective'){
		$savedKeys .= "${event}_subjective_${team}";
	}
}

sub writeDbData(){
	my ($eventCsv, $eventHeaders, $type) = @_;
	foreach my $event (keys %{$eventCsv}){
		my ($year) = $event =~ /^(20[0-9]{2})/;
		my $table = "$year$type";
		$csvHeaders = $eventHeaders->{$event};
		foreach my $row (@{$eventCsv->{$event}}){
			my $data = {};
			@$data{@$csvHeaders} = @$row;
			$db->upsert($table, $data);
			&appendSavedKey($type, $event, $data->{"match"}, $data->{"team"});
		}
		$db->commit();
	}
}

sub writeData(){
	my ($eventCsv, $eventHeaders, $type) = @_;
	if ($dbh){
		&writeDbData($eventCsv,$eventHeaders,$type);
	} else {
		&writeCsvData($eventCsv,$eventHeaders,$type);
	}
}

&writeData($scoutCsv,$scoutHeaders,'scouting');
&writeData($pitCsv,$pitHeaders,'pit');
&writeData($subjectiveCsv,$subjectiveHeaders,'subjective');

$webutil->redirect("/upload-done.html#$savedKeys");
