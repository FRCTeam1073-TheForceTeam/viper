#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use HTML::Escape qw/escape_html/;

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

my $cgi = CGI->new;
my $csv = $cgi->param('csv');
my $event = $cgi->param('event');

&error("Missing event ID") if (!$event);
&error("Malformed event ID", $event) if ($event !~ /^20[0-9]{2}[a-zA-Z0-9_\-]+$/);
&error("Missing CSV") if (!$csv);
$csv =~ s/\r\n|\r/\n/g;
&error("Malformed CSV", $csv) if (!$csv or $csv !~ /\Amatch,R1,R2,R3,B1,B2,B3\n(?:qm[0-9]+(?:,[0-9]+){6}\n)+\Z/g);

my $file = "../data/${event}.quals.csv";
&error("Error opening $file for writing", "$!") if (!open my $fh, ">", $file);
print $fh $csv;
close $fh;
&redirect("/event.html#$event");
