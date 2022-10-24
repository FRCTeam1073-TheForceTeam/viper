#!/usr/bin/perl -w

# Displays a list of files associated with a particular event

use strict;
use warnings;
use CGI;
use HTML::Escape qw/escape_html/;

my $cgi = CGI->new;

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

my $event = $cgi->param('event');

&error ("No event specified") if (!$event);
&error ("Bad event format") if ($event !~ /^20[0-9]{2}[a-zA-Z0-9_\-]+$/);

# print web page beginning
print "Content-type: text/csv; charset=UTF-8\n\n";

# get all of the event files containing match schedules
foreach my $name (split /\n/, `ls -1 -r data/$event.*`){
    print "/$name\n"
}