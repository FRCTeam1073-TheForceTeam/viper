#!/usr/bin/perl -w

use strict;
use warnings;

my $picdir = "/scoutpics";

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

my %auto;
my %teleop;
my %missed;
my %ctrl;
my @shotlocs;
for (my $i = 0; $i < 25; $i++) {
    $shotlocs[$i] = 0;
}

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
	if (defined $auto{$m}) {
		my $suffix = "a";
		while (1) {
			my $index = $m . $suffix;
			if (defined $auto{$index}) {
				++$suffix;
				next;
			} else {
				$m = $index;
				last;
			}
		}
	}
    push @match, $m;
    
    # AUTO
    # auto line
    $auto{$m}  = "<td align=center><h2>$items[3]</h2></td>";
    # auto bottom
    $auto{$m} .= "<td align=center><h2>$items[4]</h2></td>";
    # auto outer
    $auto{$m} .= "<td align=center><h2>$items[5]</h2></td>";
    # auto inner
    $auto{$m} .= "<td align=center><h2>$items[6]</h2></td>";
    
    # TELEOP
    # teleop bottom
    $teleop{$m}  = "<td align=center><h2>$items[7]</h2></td>";
    # teleop outer
    $teleop{$m} .= "<td align=center><h2>$items[8]</h2></td>";
    # teleop inner
    $teleop{$m} .= "<td align=center><h2>$items[9]</h2></td>";
    # auto missed
    $teleop{$m} .= "<td align=center><h2>$items[10]</h2></td>";
    # teleop missed
    $teleop{$m} .= "<td align=center><h2>$items[11]</h2></td>";
    
    # shotlocs
    for (my $i = 0; $i < 25; $i++) {
		$shotlocs[$i]++ if ("$items[$i+12]" eq "1");
    }

    # Control Panel
    # rotation
    my $answer = "No";
    $answer = "Yes" if ("$items[37]" eq "1");
    $ctrl{$m}  = "<td align=center><h2>$answer</h2></td>";
    # position
    $answer = "No";
    $answer = "Yes" if ("$items[38]" eq "1");
    $ctrl{$m} .= "<td align=center><h2>$answer</h2></td>"; 

    # park
    $answer = "No";
    $answer = "Yes" if ("$items[39]" eq "1");
    $ctrl{$m} .= "<td align=center><h2>$answer</h2></td>";

    # climb
    $answer = "No";
    $answer = "Yes" if ("$items[40]" eq "1");
    $ctrl{$m} .= "<td align=center><h2>$answer</h2></td>";
    # bar
    $answer = "N/A";
    $answer = "Low" if ("$items[41]" eq "1");
    $answer = "Level" if ("$items[41]" eq "2");
    $answer = "High" if ("$items[41]" eq "3");
    $ctrl{$m} .= "<td align=center><h2>$answer</h2></td>";
    # buddy
    $answer = "No";
    $answer = "Yes" if ("$items[42]" eq "1");
    $ctrl{$m} .= "<td align=center><h2>$answer</h2></td>";
    # level
    $answer = "No";
    $answer = "Yes" if ("$items[43]" eq "1");
    $ctrl{$m} .= "<td align=center><h2>$answer</h2></td>";
    
    # DEFENSE & FOULS
    # defense
    $answer = "None";
    $answer = "Poor" if ("$items[44]" eq "1");
    $answer = "Average" if ("$items[44]" eq "2");
    $answer = "Good" if ("$items[44]" eq "3");
    $defoul{$m}  = "<td align=center><h2>$answer</h2></td>";
    # defended
    $answer = "None";
    $answer = "Poor" if ("$items[45]" eq "1");
    $answer = "Average" if ("$items[45]" eq "2");
    $answer = "Good" if ("$items[45]" eq "3");
    $defoul{$m} .= "<td align=center><h2>$answer</h2></td>";
    # fouls
    $answer = "None";
    $answer = "One" if ("$items[46]" eq "1");
    $answer = "A Few" if ("$items[46]" eq "2");
    $answer = "Many" if ("$items[46]" eq "3");
    $defoul{$m} .= "<td align=center><h2>$answer</h2></td>";
    # tech fouls
    $answer = "None";
    $answer = "One" if ("$items[47]" eq "1");
    $answer = "A Few" if ("$items[47]" eq "2");
    $answer = "Many" if ("$items[47]" eq "3");
    $defoul{$m} .= "<td align=center><h2>$answer</h2></td>";
    
    # SCOUT INPUT
    # rank
    $answer = "unknown";
    $answer = "struggled" if ("$items[48]" eq "1");
    $answer = "decent" if ("$items[48]" eq "2");
    $answer = "very good" if ("$items[48]" eq "3");
    $scout{$m} .= "<td align=center><h2>$answer</h2></td>";
    # name
    if (@items > 48) {
        my $str = $items[49];
	$str =~ tr/+/ /;
        $scout{$m} .= "<td align=center><h2>$str</h2></td>";
    } else {
        $scout{$m} .= "<td>&nbsp;</td>";
    }
    # comments
    if (@items > 49) {
        my $str = $items[50];
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
print "<tr><td colspan=10 align=center><H2>Initiation Line and Power Cell Counts</h2></td></tr>\n";
print "<tr><th>Match</th><th>Auto<br>Line</th><th>Auto<BR>Bottom</th><th>Auto<br>Outer</th><th>Auto<br>Inner</th>";
print "<th>TeleOp<br>Bottom</th><th>TeleOp<br>Outer</th><th>TeleOp<br>Inner</th><th>Auto<br>Missed</th><th>TeleOp<br>Missed</th></tr>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$auto{$m}$teleop{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=8 align=center><H2>Control Panel & End Game</h2></td></tr>\n";
print "<tr><th>Match</th><th>Rotation</th><th>Position</th>";
print "<th>Park</th><th>Climb</th><th>Bar Pos</th><th>BuddyLift</th><th>Level</th>";

foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$ctrl{$m}</tr>\n";
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
print "<tr><td colspan=4 align=center><H2>Scouter Input Table</h2></td></tr>\n";
print "<tr><th>Match</th><th>Rank</th><th>Name</th><th>Comments</th>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$scout{$m}</tr>\n";
}
print "</table>\n";

print "<hr>\n";
print "<H2>Shooting Locations</H2>\n";
print "<table cellspacing=0 cellpadding=0 border=1 bordercolor=red>\n";
my $index = 0;
for (my $j = 1; $j < 6; $j++) {
    print "<tr>\n";
    for (my $i = 1; $i < 6; $i++) {
	my $mark = "";
	$mark = "_X" if ("$shotlocs[$index]" ne "0");
	print "<td><img src=$picdir/left_red_${j}_${i}${mark}.png></td>\n";
	$index++;
    }
    print "</tr>\n";
}
print "</table>\n";

print "<hr>\n";
print "<H2>Number of games $team shot from each location</H2>\n";
print "<table cellspacing=0 cellpadding=5 border=1 bordercolor=red>\n";
$index = 0;
for (my $j = 1; $j < 6; $j++) {
    print "<tr>\n";
    for (my $i = 1; $i < 6; $i++) {
	print "<td><p style=\"font-size:30px; font-weight:bold;\">$shotlocs[$index]</p></td>\n";
	$index++;
    }
    print "</tr>\n";
}
print "</table>\n";

print "</body></html>\n";
