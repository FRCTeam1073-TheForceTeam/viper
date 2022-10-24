#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Data::Dumper;
use HTML::Escape qw/escape_html/;
use Fcntl qw(:flock SEEK_END);

my $cgi = CGI->new;

sub redirect {
    my ($url) = @_;
    $url = "http".($ENV{'PORT'}==443?"s":"")."://".$ENV{'SERVER_NAME'}.$url if ($url =~ /^\//);
    print "Location: $url\n\n";
    exit 0;
}

sub error {
    my ($title, $help) = @_;
    print "Content-type: text/html; charset=UTF-8\n\n";
    print "<!DOCTYPE html>\n";
    print "<html>\n";
    print "<head>\n";
    print "<title>".escape_html($title)."</title>\n";
    print "</head>\n";
    print "<body>\n";
    print "<center>\n";
    print "<h1 style=color:red>".escape_html($title)."</h1>\n";
    print "<pre>".escape_html($help)."</pre>\n";
    print "</center>\n";
    print "</body>\n";
    print "</html>\n";
    exit 0;
}

my $uCsv = $cgi->param('csv');
&error("No data uploaded", "Scouting CSV data not found.") if (!$uCsv);
$uCsv = [ map { [ split(/,/, $_, -1) ] } split(/[\r\n]+/, $uCsv) ];
&error("Not enough CSV lines", "expected at least two lines in uploaded CSV") if(scalar(@{$uCsv})<2);
my $csvHeaders =  shift @{$uCsv};
my $uHead = { map { $csvHeaders->[$_] => $_ } 0..(scalar(@{$csvHeaders})-1) };
foreach my $key (qw(event match team)){
    &error("Missing column", "Expected $key CSV heading") if (! exists $uHead->{$key});
}
my $events = {};
foreach my $name (@{$csvHeaders}){
    &error("Unexpected CSV heading",$name) if($name !~ /^[a-zA-Z0-9_\-]+$/);
}
foreach my $row (@{$uCsv}){
    &error("Bad row size", "CSV row size (".(scalar @{$row}).") doesn't match heading row size(".(scalar keys %{$uHead}).")\n".join(",",keys %{$uHead})."\n".join(",", @{$row})) if (scalar keys %{$uHead} != scalar @{$row});
    &error("Unexpected event name",$row->[$uHead->{'event'}]) if($row->[$uHead->{'event'}] !~ /^20\d\d[a-zA-Z0-9_\-]+$/);
    &error("Unexpected event name",$row->[$uHead->{'match'}]) if($row->[$uHead->{'match'}] !~ /^[a-z]+[0-9]+$/);
    &error("Unexpected event name",$row->[$uHead->{'team'}]) if($row->[$uHead->{'team'}] !~ /^[0-9]+$/);
    $events->{$row->[$uHead->{'event'}]} = [] if (! exists  $events->{$row->[$uHead->{'event'}]});
    push(@{$events->{$row->[$uHead->{'event'}]}}, $row)
}

my $savedKeys = "";
foreach my $event (keys %{$events}){
    my $fileName = "../data/" . $event . ".txt";
    if (! -f $fileName){
	    `touch $fileName`;
    }
     
    open my $fh, '+<', $fileName or &error("Cannot open $fileName", "$!\n");
    flock($fh, LOCK_EX) or &error("Cannot lock $fileName", "$!\n");
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
    print $fh join(",", @$csvHeaders)."\n";
    foreach my $row (@$fCsv){
        my $first = 1;
        foreach my $name (@$csvHeaders){
            print $fh "," if (!$first);
            print $fh $row->[$fHead->{$name}] if (defined $fHead->{$name});
            $first = 0;
        }
        print $fh "\n";
    }
    foreach my $row (@$uCsv){
        my $first = 1;
        foreach my $name (@$csvHeaders){
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
&redirect("/upload-done.html#$savedKeys");
