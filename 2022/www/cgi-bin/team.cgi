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
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#ffffff\"><center>\n";

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

my %game;
my %field;
my %review;
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
    next if (@items < 25 || $items[0] eq "event");
    my $t = $items[2];
    next unless ($team eq $t);
    my $m = $items[1];
    # guard against duplicate match entries
    if (defined $game{$m}) {
	my $suffix = "a";
	while (1) {
	    my $index = $m . $suffix;
	    if (defined $game{$index}) {
		++$suffix;
		next;
	    } else {
		$m = $index;
		last;
	    }
	}
    }
    push @match, $m;
    #
    # event=0, match=1, team=2
    # taxi=3,human=4,alo=5,ahi=6,ami=7,abnc=8
    # tlo=9,thi=10,tmi=11,tbnc=12
    # hub=13,field=14,outer=15,wall=16,rung=17
    # defense=18,defend=19,fouls=20,tech=21,scout=22
    #
    # GAME
    # auto taxi
    $game{$m}  = "<td align=center bgcolor=\"#dddddd\"><font size=+2>$items[3]</font></td>";
    # auto human
    $game{$m} .= "<td align=center bgcolor=\"#dddddd\"><font size=+2>$items[4]</font></td>";
    # auto lower hub
    $game{$m} .= "<td align=center><font size=+2>$items[5]</font></td>";
    # auto upper hub
    $game{$m} .= "<td align=center><font size=+2>$items[6]</font></td>";
    # tele lower hub
    $game{$m} .= "<td align=center><font size=+2>$items[9]</font></td>";
    # tele upper hub
    $game{$m} .= "<td align=center><font size=+2>$items[10]</font></td>";
    # auto missed
    $game{$m} .= "<td align=center bgcolor=\"#dddddd\"><font size=+2>$items[7]</font></td>";
    # tele missed
    $game{$m} .= "<td align=center bgcolor=\"#dddddd\"><font size=+2>$items[11]</font></td>";
    # auto bounced
    $game{$m} .= "<td align=center bgcolor=\"#dddddd\"><font size=+2>$items[8]</font></td>";
    # tele bounced
    $game{$m} .= "<td align=center bgcolor=\"#dddddd\"><font size=+2>$items[12]</font></td>";
    # FIELD
    # shot from hub
    my $answer = "No";
    $answer = "Yes" if ("$items[13]" ne "0");
    $field{$m} = "<td align=center><font size=+2>$answer</font></td>";
    # shot from field
    $answer = "No";
    $answer = "Yes" if ("$items[14]" ne "0");
    $field{$m} .= "<td align=center><font size=+2>$answer</font></td>";
    # shot from outer launch pad
    $answer = "No";
    $answer = "Yes" if ("$items[15]" ne "0");
    $field{$m} .= "<td align=center><font size=+2>$answer</font></td>";
    # shot from wall launch pad
    $answer = "No";
    $answer = "Yes" if ("$items[16]" ne "0");
    $field{$m}  .= "<td align=center><font size=+2>$answer</font></td>";
    # rung
    $answer = "None";
    $answer = "Low"       if ("$items[17]" eq "1");
    $answer = "Middle"    if ("$items[17]" eq "2");
    $answer = "High"      if ("$items[17]" eq "3");
    $answer = "Traversal" if ("$items[17]" eq "4");
    $field{$m} .= "<td align=center><font size=+2>$answer</font></td>";
    
    # REVIEW
    # defense
    $answer = "None";
    $answer = "Poor" if ("$items[18]" eq "1");
    $answer = "Average" if ("$items[18]" eq "2");
    $answer = "Good" if ("$items[18]" eq "3");
    $review{$m}  = "<td align=center><font size=+2>$answer</font></td>";
    # defended
    $answer = "None";
    $answer = "Poor" if ("$items[19]" eq "1");
    $answer = "Average" if ("$items[19]" eq "2");
    $answer = "Good" if ("$items[19]" eq "3");
    $review{$m} .= "<td align=center><font size=+2>$answer</font></td>";
    # fouls
    $answer = "None";
    $answer = "One" if ("$items[20]" eq "1");
    $answer = "Two" if ("$items[20]" eq "2");
    $answer = "Three+" if ("$items[20]" eq "3");
    $review{$m} .= "<td align=center><font size=+2>$answer</font></td>";
    # tech fouls
    $answer = "None";
    $answer = "One" if ("$items[21]" eq "1");
    $answer = "Two" if ("$items[21]" eq "2");
    $answer = "Three+" if ("$items[21]" eq "3");
    $review{$m} .= "<td align=center><font size=+2>$answer</font></td>";
    # rank
    $answer = "unknown";
    $answer = "struggled" if ("$items[22]" eq "1");
    $answer = "decent" if ("$items[22]" eq "2");
    $answer = "very good" if ("$items[22]" eq "3");
    $review{$m} .= "<td align=center><font size=+2>$answer</font></td>";

    # SCOUT
    # name
    if (@items > 22) {
        my $str = $items[23];
	$str =~ tr/+/ /;
        $scout{$m} = "<td align=center><font size+=2>$str</font></td>";
    } else {
        $scout{$m} = "<td>&nbsp;</td>";
    }
    # comments
    if (@items > 23) {
        my $str = $items[24];
	$str =~ tr/+/ /;
	$str =~ s/%2C/,/g;
	$str =~ s/%27/'/g;
	$str =~ s/%3A/:/g;
	$str =~ s/%0A/<BR>/g;
	$str =~ s/%0D//g;
        $scout{$m} .= "<td align=center><font size=+2>$str</font></td>";
    } else {
        $scout{$m} .= "<td>&nbsp;</td>";
    }
}

# game = 11
# field = 6
# review = 6
# scouting = 3

print "<H1>$team</H1>\n";
print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=11 align=center><FONT SIZE=+2>Game: Auto, TeleOp Cargo</FONT></td></tr>\n";
print "<tr><th>Match</th><th>Taxi</th><th>Human</th>\n";
print "<th>Auto<br>Lower</th><th>Auto<br>Upper</th><th>TeleOp<br>Lower</th><th>TeleOp<br>Upper</th>\n";
print "<th>Auto<br>Missed</th><th>TeleOp<br>Missed</th><th>Auto<br>Bounced</th><th>TeleOp<br>Bounced</th>\n";
#print "<th>Shoot<br>Hub</th><th>Shoot<br>Field</th><th>Shoot<br>Outer LP</th><th>Shoot<br>Wall LP</th>\n";
#print "<th>EndGame<br>Rung</th>\n";
print "</tr><tr>\n";
foreach my $m (@match) {
    print "<tr><td><font size=+2>$m</font></td>$game{$m}</tr>\n";
}
print "</table>\n";

print "<table cellspacing=5 cellpadding=5 border=1>\n";
print "<tr><td colspan=6 align=center><font size=+2>Shooting Location and EndGame</font></td></tr>\n";
print "<tr><th>Match</th><th>Shoot<br>Hub</th><th>Shoot<br>Field</th><th>Shoot<br>Outer LP</th><th>Shoot<br>Wall LP</th>\n";
print "<th>EndGame<br>Rung</th></tr>\n";
foreach my $m (@match) {
    print "<tr><td><font size=+2>$m</font></td>$field{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=6 align=center><font size=+2>Game Review</font></td></tr>\n";
print "<tr><th>Match</th><th>Played<br>Defense</th><th>Against<br>Defense</th>";
print "<th>Fouls</th><th>Tech<br>Fouls</th><th>Rank</th></tr>\n";

foreach my $m (@match) {
    print "<tr><td><font size=+2>$m</font></td>$review{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=3 align=center><font size=+2>Scouter and Comments</font></td></tr>\n";
print "<tr><th>Match</th><th>Name</th><th>Comments</th></tr>";
foreach my $m (@match) {
    print "<tr><td><font size=+2>$m</font></td>$scout{$m}</tr>\n";
}
print "</table>\n";

print "</body></html>\n";
