#!/usr/bin/perl -w

use strict;
use warnings;

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
    print "<title>$title</title>\n";
    print "</head>\n";
    print "<body>\n";
    print "<center>\n";
    print "<h1 style=color:red>$title</h1>\n";
    print "<h3>$help</h3>\n";
    print "</center>\n";
    print "</body>\n";
    print "</html>\n";
    exit 0;
}

#
# parse input
#
my %params;
if (exists $ENV{'QUERY_STRING'}) {
    my @args = split /\&/, $ENV{'QUERY_STRING'};
    foreach my $arg (@args) {
        my @bits = split /=/, $arg;
        next unless (@bits == 2);
        $params{$bits[0]} = $bits[1];
    }
}

if (exists $ENV{'CONTENT_LENGTH'}) {
    my $content = $ENV{'CONTENT_LENGTH'};
    if ($content > 0) {
        my $data = <STDIN>;
        my @args = split /\&/, $data;
        foreach my $arg (@args) {
            my @bits = split /=/, $arg;
            next unless (@bits == 2);
            $params{$bits[0]} = $bits[1];
        }
    }
}

sub getMatchData {
    my ($matchNum) = @_;
    my $matchData = "qm$matchNum";
    for my $robot ("R1","R2","R3","B1","B2","B3"){
        my $key = "Q${matchNum}${robot}";
        return 0 if (!defined($params{$key}) || $params{$key} !~ /[0-9]{1,6}/);
        $matchData .= ",".$params{$key};
    }
    return $matchData
}

my $event_year =  defined $params{'event_year'} ? $params{'event_year'} : "";
&error("Event year missing", "Click back and make sure to specify the event year") if (!$event_year);
&error("Event year malformed", "Click back and type in the full four digit year") if ($event_year !~ /^20[0-9]{2}$/);
my $event_venue =  defined $params{'event_venue'} ? $params{'event_venue'} : "";
&error("Event venue missing", "Click back and make sure to specify the event venue") if (!$event_venue);
&error("Event venue malformed", "Click back and remove the spaces and/or special characters") if ($event_venue !~ /^[a-zA-Z0-9_-]+$/);
&error("No match data", "Click back and add match data")if (!&getMatchData(1));

my $event = "${event_year}${event_venue}";

my $file = "../data/${event}.dat";
&error("Error opening $file for writing: $!", "") if (!open my $fh, ">", $file);

my $matchData = "";
print $fh "match,R1,R2,R3,B1,B2,B3\n";
for (my $i = 1; $matchData = &getMatchData($i); $i++) {
    print $fh "$matchData\n";
}
close $fh;
&redirect("/event.html#$event");
