#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Data::Dumper;
use HTML::Escape qw/escape_html/;
use Fcntl qw(:flock SEEK_END);
use lib '../../pm';
use csv;
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;

my $uCsv = $cgi->param('csv');
$webutil->error("No data uploaded", "Scouting CSV data not found.") if (!$uCsv);
$uCsv = [ map { [ split(/,/, $_, -1) ] } split(/[\r\n]+/, $uCsv) ];
$webutil->error("Not enough CSV lines", "expected at least two lines in uploaded CSV") if(scalar(@{$uCsv})<2);
my $next = $cgi->param('next')|"";
webutil->error("Bad next", $next) if ($next and $next !~ /^\/20[0-9]{2}\/scout\.html\#[a-zA-Z0-9\=\&]+$/);
$next = "#$next" if ($next);
my $csvHeaders;
my $uHead;
my $eventCsv = {};
my $eventHeaders = {};
foreach my $row (@{$uCsv}){
	if ($row->[0] eq 'event'){
		$csvHeaders = $row;
		$uHead = { map { $csvHeaders->[$_] => $_ } 0..(scalar(@{$csvHeaders})-1) };
		foreach my $key (qw(event match team)){
			$webutil->error("Missing column", "Expected $key CSV heading") if (! exists $uHead->{$key});
		}
		foreach my $name (@{$csvHeaders}){
			$webutil->error("Unexpected CSV heading",$name) if($name !~ /^[a-zA-Z0-9_\-]+$/);
		}
	} else {
		$webutil->error("Didn't find a header row starting with 'event' before other data") if (!$csvHeaders);
		$webutil->error("Bad row size", "CSV row size (".(scalar @{$row}).") doesn't match heading row size(".(scalar keys %{$uHead}).")\n".join(",",keys %{$uHead})."\n".join(",", @{$row})) if (scalar keys %{$uHead} != scalar @{$row});
		$webutil->error("Unexpected event name",$row->[$uHead->{'event'}]) if($row->[$uHead->{'event'}] !~ /^20\d\d[a-zA-Z0-9_\-]+$/);
		$webutil->error("Unexpected event name",$row->[$uHead->{'match'}]) if($row->[$uHead->{'match'}] !~ /^[a-z]+[0-9]+$/);
		$webutil->error("Unexpected event name",$row->[$uHead->{'team'}]) if($row->[$uHead->{'team'}] !~ /^[0-9]+$/);
		$eventCsv->{$row->[$uHead->{'event'}]} = [] if (! exists  $eventCsv->{$row->[$uHead->{'event'}]});
		$eventHeaders->{$row->[$uHead->{'event'}]} = $csvHeaders;
		push(@{$eventCsv->{$row->[$uHead->{'event'}]}}, $row)
	}
}

my $savedKeys = "";
foreach my $event (keys %{$eventCsv}){
	my $fileName = "../data/" . $event . ".scouting.csv";
	if (! -f $fileName){
		`touch $fileName`;
	}
	$csvHeaders = $eventHeaders->{$event};

	open my $fh, '+<', $fileName or $webutil->error("Cannot open $fileName", "$!\n");
	flock($fh, LOCK_EX) or $webutil->error("Cannot lock $fileName", "$!\n");
	$/ = undef;
	my $fCsv = <$fh>;
	$fCsv = [ map { [ split(/,/, $_, -1) ] } split(/[\r\n]+/, $fCsv) ];
	my $fHead = shift @{$fCsv};
	for my $name (@{$fHead}){
		push(@{$csvHeaders}, $name) if (!defined $uHead->{$name});
	}
	$fHead = { map { $fHead->[$_] => $_ } 0..(scalar(@{$fHead})-1) };
	seek $fh, 0, 0;
	truncate $fh, 0;
	print $fh join(",", @{$csvHeaders})."\n";
	foreach my $row (@$fCsv){
		my $first = 1;
		foreach my $name (@{$csvHeaders}){
			print $fh "," if (!$first);
			print $fh $row->[$fHead->{$name}] if (defined $fHead->{$name});
			$first = 0;
		}
		print $fh "\n";
	}
	foreach my $row (@{$eventCsv->{$event}}){
		my $first = 1;
		foreach my $name (@{$csvHeaders}){
			print $fh "," if (!$first);
			print $fh $row->[$uHead->{$name}] if (defined $uHead->{$name});
			$first = 0;
		}
		print $fh "\n";
		$savedKeys .= "," if($savedKeys);
		$savedKeys .= $row->[$uHead->{"event"}]."_".$row->[$uHead->{"match"}]."_".$row->[$uHead->{"team"}];
	}
	close $fh;
}

$webutil->redirect("/upload-done.html#$savedKeys$next");
