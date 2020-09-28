#!/usr/bin/perl -w

use strict;
use warnings;

my $event = "";
my $team = "";

#
# read in given game data
#
if ($ENV{QUERY_STRING}) {
    my @args = split /\&/, $ENV{QUERY_STRING};
    my %params;
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
    $event = $params{'event'} if (defined $params{'event'});
    $team  = $params{'team'}  if (defined $params{'team'});
    
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";

if ($event eq "") {
    print "<H2>Error, need an event</H2>\n";
    print "</body></html>\n";
    exit 0;
}

if ($team eq "") {
    print "<H2>Error, need a team</H2>\n";
    print "</body></html>\n";
    exit 0;
}


my $file = "/var/www/html/csv/${event}.txt";
if (! -f $file) {
    print "<H2>Error, file $file does not exist</H2>\n";
    print "</body></html>\n";
    exit 0;
}

my %summary;
my %auto;
my %teleop;
my %defoul;
my %scout;
my @match;
my $fh;
if (! open($fh, "<", $file) ) {
    print "<H2>Error, cannot open $file for reading: $!</H2>\n";
    print "</body></html>\n";
    exit 0;
}
    
while (my $line = <$fh>) {
    my @items = split /,/, $line;
    next if (@items < 27 || $items[0] eq "event");
    my $t = $items[2];
    next unless ($team eq $t);
    my $m = $items[1];
	# guard against duplicate match entries
	if (defined $summary{$m}) {
		my $suffix = "a";
		while (1) {
			my $index = $m . $suffix;
			if (defined $summary{$index}) {
				++$suffix;
				next;
			} else {
				$m = $index;
				last;
			}
		}
	}
    push @match, $m;
    
    # SUMMARY
    # start level
    $summary{$m}  = "<td align=center><h2>$items[3]</h2></td>";
    # total hatches
    $summary{$m} .= "<td align=center><h2>$items[4]</h2></td>";
    # total cargo
    $summary{$m} .= "<td align=center><h2>$items[5]</h2></td>";
    # end level
    $summary{$m} .= "<td align=center><h2>$items[6]</h2></td>";
    
    # AUTO
    # auto hatch ship
    $auto{$m}  = "<td align=center><h2>$items[7]</h2></td>";
    # auto cargo ship
    $auto{$m} .= "<td align=center><h2>$items[8]</h2></td>";
    # auto hatch r1
    $auto{$m} .= "<td align=center><h2>$items[9]</h2></td>";
    # auto hatch r2
    $auto{$m} .= "<td align=center><h2>$items[10]</h2></td>";
    # auto hatch r3
    $auto{$m} .= "<td align=center><h2>$items[11]</h2></td>";
    # auto cargo r1
    $auto{$m} .= "<td align=center><h2>$items[12]</h2></td>";
    # auto cargo r2
    $auto{$m} .= "<td align=center><h2>$items[13]</h2></td>";
    # auto cargo r3
    $auto{$m} .= "<td align=center><h2>$items[14]</h2></td>";
    
    # TELEOP
    # hatch ship
    $teleop{$m}  = "<td align=center><h2>$items[15]</h2></td>";
    # hatch r1
    $teleop{$m} .= "<td align=center><h2>$items[16]</h2></td>";
    # hatch r2
    $teleop{$m} .= "<td align=center><h2>$items[17]</h2></td>";
    # hatch r3
    $teleop{$m} .= "<td align=center><h2>$items[18]</h2></td>";
    # cargo ship
    $teleop{$m} .= "<td align=center><h2>$items[19]</h2></td>";
    # cargo r1
    $teleop{$m} .= "<td align=center><h2>$items[20]</h2></td>";
    # cargo r2
    $teleop{$m} .= "<td align=center><h2>$items[21]</h2></td>";
    # cargo r3
    $teleop{$m} .= "<td align=center><h2>$items[22]</h2></td>";
    
    # DEFENSE & FOULS
    # defense
    $defoul{$m}  = "<td align=center><h2>$items[23]</h2></td>";
    # defended
    $defoul{$m} .= "<td align=center><h2>$items[24]</h2></td>";
    # fouls
    $defoul{$m} .= "<td align=center><h2>$items[25]</h2></td>";
    # tech fouls
    $defoul{$m} .= "<td align=center><h2>$items[26]</h2></td>";
    
    # SCOUT INPUT
    # rank
    $scout{$m} .= "<td align=center><h2>$items[27]</h2></td>";
    # name
    if (@items > 27) {
        my $str = $items[28];
	$str =~ tr/+/ /;
        $scout{$m} .= "<td align=center><h2>$str</h2></td>";
    } else {
        $scout{$m} .= "<td>&nbsp;</td>";
    }
    # comments
    if (@items > 28) {
        my $str = $items[29];
	$str =~ tr/+/ /;
	$str =~ s/%2C/,/g;
	$str =~ s/%27/'/g;
	$str =~ s/%3A/:/g;
	$str =~ s/%0A/<BR>/g;
	$str =~ s/%0D//g;
        $scout{$m} .= "<td align=center><h2>$str</h2></td>";
    } else {
        $scout{$m} .= "<td>&nbsp;</td>";
    }
}


print "<H1>$team</H1>\n";
print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=5 align=center><H2>Summary Table</h2></td></tr>\n";
print "<tr><th>Match</th><th>Start Level</th><th>Total Hatches</th>";
print "<th>Total Cargo</th><th>End Level</th></tr>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$summary{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=9 align=center><H2>Autonomous Table</h2></td></tr>\n";
print "<tr><th>Match</th><th>Ship Hatch</th><th>Ship Cargo</th>";
print "<th>Rocket Hatch Low</th><th>Rocket Cargo Low</th>";
print "<th>Rocket Hatch Mid</th><th>Rocket Cargo Mid</th>";
print "<th>Rocket Hatch Hi</th><th>Rocket Cargo Hi</th></tr>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$auto{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=9 align=center><H2>TeleOp Table</h2></td></tr>\n";
print "<tr><th>Match</th><th>Ship Hatch</th><th>Rocket Hatch Low</th>";
print "<th>Rocket Hatch Mid</th><th>Rocket Hatch High</th>";
print "<th>Ship Cargo</th><th>Rocket Cargo Low</th>";
print "<th>Rocket Cargo Mid</th><th>Rocket Cargo High</th></tr>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$teleop{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=6 align=center><H2>Defense & Fouls Table</h2></td></tr>\n";
print "<tr><th>Match</th><th>Defense</th><th>Defended</th>";
print "<th>Fouls</th><th>Tech Fouls</th></tr>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$defoul{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=6 align=center><H2>Scouter Input Table</h2></td></tr>\n";
print "<tr><th>Match</th><th>Rank</th><th>Name</th><th>Comments</th>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$scout{$m}</tr>\n";
}
print "</table>\n";


print "</body></html>\n";
