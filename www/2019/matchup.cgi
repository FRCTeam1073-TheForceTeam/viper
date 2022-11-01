#!/usr/bin/perl -w

use strict;
use warnings;

my $event = "";
my @red;
my @blue;

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
	$event = $params{'event'}  if (defined $params{'event'});
	push @red, $params{'r1'} if (defined $params{'r1'});
	push @red, $params{'r2'} if (defined $params{'r2'});
	push @red, $params{'r3'} if (defined $params{'r3'});
	push @blue, $params{'b1'} if (defined $params{'b1'});
	push @blue, $params{'b2'} if (defined $params{'b2'});
	push @blue, $params{'b3'} if (defined $params{'b3'});
}

# print web page beginning
print "Content-type: text/html; charset=UTF-8\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";
print "<h1>Match Predictor</h1>\n";
print "<p><a href=\"index.cgi\">Home</a></p>\n";
if ($event eq "") {
    print "<h2>Error, need an event</h2>\n";
    print "</body></html>\n";
    exit 0;
}

#
# Load event data
#
my $file = "../data/${event}.scouting.csv";
if (! -f $file) {
    print "<h2>Error, file $file does not exist</h2>\n";
    print "</body></html>\n";
    exit 0;
}

my %teamScore;
my %teamHatch;
my %teamCargo;
my %teamEnd1;
my %teamEnd2;
my %teamEnd3;
my %teamCount;
if ( open(my $fh, "<", $file) ) {
    while (my $line = <$fh>) {
		my @items = split /,/, $line;
		next if (@items < 6 || $items[0] eq "event");
		my $team  = $items[2];
		my $start = int $items[3];
		my $hatch = int $items[4];
		my $cargo = int $items[5];
		my $fini  = int $items[6];
		$teamScore{$team} = 0 unless (defined $teamScore{$team});
		$teamHatch{$team} = 0 unless (defined $teamHatch{$team});
		$teamCargo{$team} = 0 unless (defined $teamCargo{$team});
		$teamEnd1{$team} = 0 unless (defined $teamEnd1{$team});
		$teamEnd2{$team} = 0 unless (defined $teamEnd2{$team});
		$teamEnd3{$team} = 0 unless (defined $teamEnd3{$team});
		
		$teamScore{$team} += ($start * 3) + ($hatch * 2) + ($cargo * 3) + ($fini * 3);
		$teamScore{$team} += 3 if ($fini == 3);
		$teamHatch{$team} += $hatch;
		$teamCargo{$team} += $cargo;
		$teamEnd1{$team} += 1 if ($fini == 1);
		$teamEnd2{$team} += 1 if ($fini == 2);
		$teamEnd3{$team} += 1 if ($fini == 3);
		if (defined $teamCount{$team}) {
			$teamCount{$team} += 1;
		} else {
			$teamCount{$team} = 1;
		}
	}
    close $fh;
} else {
    print "<h2>Error, could not open $file: $!</h2>\n";
    print "</body></html>\n";
    exit 0;
}

sub printTeam {
    my ($pos, $team) = (@_);
    print "<td>$pos</td><td>";
    if ($team ne "") {
        print "$team";
    } else {
        print "&nbsp;";
    }
    print "</td>\n";
}

# provide team selection if teams not given
if (@red != 3 || @blue != 3) {
    print "<form action=\"matchup.cgi\">\n";
    print "<input type=\"hidden\" name=\"r1\" value=\"$red[0]\">" if (@red > 0);
    print "<input type=\"hidden\" name=\"r2\" value=\"$red[1]\">" if (@red > 1);
    print "<input type=\"hidden\" name=\"r3\" value=\"$red[2]\">" if (@red > 2);
    print "<input type=\"hidden\" name=\"b1\" value=\"$blue[0]\">" if (@blue > 0);
    print "<input type=\"hidden\" name=\"b2\" value=\"$blue[1]\">" if (@blue > 1);
    print "<input type=\"hidden\" name=\"b3\" value=\"$blue[2]\">" if (@blue > 2);

    print "<table cellpadding=5 cellspacing=5 border=1>\n";
    my $filler = "&nbsp;";
    $filler = $red[0] if (@red > 0);
    print "<tr><td>Red 1</td><td>$filler</td>\n";
    $filler = "&nbsp;";
    $filler = $blue[0] if (@blue > 0);
    print "<td>Blue 1</td><td>$filler</td></tr>\n";
    print "</tr><tr>\n";
    $filler = "&nbsp;";
    $filler = $red[1] if (@red > 1);
    print "<tr><td>Red 2</td><td>$filler</td>\n";
    $filler = "&nbsp;";
    $filler = $blue[1] if (@blue > 1);
    print "<td>Blue 2</td><td>$filler</td></tr>\n";
    print "</tr><tr>\n";
    $filler = "&nbsp;";
    $filler = $red[2] if (@red > 2);
    print "<tr><td>Red 3</td><td>$filler</td>\n";
    $filler = "&nbsp;";
    $filler = $blue[2] if (@blue > 2);
    print "<td>Blue 3</td><td>$filler</td></tr>\n";
    print "</tr></table>\n";

    my $pos = "Red 1";
    my $link = "matchup.cgi?event=${event}&r1=";
    if (@red == 1) {
        $pos = "Red 2";
	$link = "matchup.cgi?event=${event}&r1=$red[0]&r2=";
    }
    if (@red == 2) {
        $pos = "Red 3";
	$link = "matchup.cgi?event=${event}&r1=$red[0]&r2=$red[1]&r3=";
    }
    if (@red == 3) {
        $pos = "Blue 1";
	$link = "matchup.cgi?event=${event}&r1=$red[0]&r2=$red[1]&r3=$red[2]&b1=";
    }
    if (@blue == 1) {
        $pos = "Blue 2";
	$link = "matchup.cgi?event=${event}&r1=$red[0]&r2=$red[1]&r3=$red[2]&b1=$blue[0]&b2=";
    }
    if (@blue == 2) {
        $pos = "Blue 3";
	$link = "matchup.cgi?event=${event}&r1=$red[0]&r2=$red[1]&r3=$red[2]&b1=$blue[0]&b2=$blue[1]&b3=";
    }
    

    print "<h3>Select ${pos}:</h3>\n";
    my @teams = sort(keys %teamScore);
    print "<table cellpadding=5 cellspacing=5 border=1><tr>\n";
    my $count = 0;
    foreach my $t (@teams) {
    	my $found = 0;
	foreach my $c (@red, @blue) {
		if ($c eq $t) {
			$found = 1;
			last;
		}
	}
	next if ($found != 0);
        print "<td><a href=\"${link}$t\">$t</a></td>\n";
	$count++;
	print "</tr><tr>\n" if ($count % 7 == 0);
    }
    while ($count % 7 != 0) {
    	$count++;
	print "<td>&nbsp;</td>\n";
    }
    print "</tr></table>\n";
    print "</body></html>\n";
    exit 0;
}

#print "<table cellpadding=5 cellspacing=5 border=1>\n";
#print "<tr><th>Red Alliance</th><th>Blue Alliance</th></tr>\n";
#for (my $i = 0; $i < 3; $i++) {
#	print "<tr><td>$red[$i]</td><td>$blue[$i]</td></tr>\n";
#}
#print "</table>\n";

# RED
print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><th colspan=7><h2>Red Alliance</h2></th></tr>\n";
print "<tr><th>Team</th><th>OPR</th>";
print "<th>Avg. #Hatches</th><th>Avg. #Cargo</th>";
print "<th>Avg Lvl 3</th><th>Avg Lvl 2</th><th>Avg Lvl 1</th></tr>\n";

my $redtotal = 0;
for (my $i = 0; $i < 3; $i++) {
	my $opr   = $teamScore{$red[$i]} / $teamCount{$red[$i]};
	my $hatch = $teamHatch{$red[$i]} / $teamCount{$red[$i]};
	my $cargo = $teamCargo{$red[$i]} / $teamCount{$red[$i]};
	my $end1  = $teamEnd1{$red[$i]} / $teamCount{$red[$i]};
	my $end2  = $teamEnd2{$red[$i]} / $teamCount{$red[$i]};
	my $end3  = $teamEnd3{$red[$i]} / $teamCount{$red[$i]};
	$redtotal += $opr;
	my $ostr = sprintf "%.3f", $opr;
	print "<tr><td><h2>";
	print "<a href=\"team.cgi?team=$red[$i]&event=$event\">$red[$i]</a></h2></td>";
	print "<td><h2>$ostr</h2></td>";
	my $hstr = sprintf "%.3f", $hatch;
	my $cstr = sprintf "%.3f", $cargo;
	my $e1st = sprintf "%.3f", $end1;
	my $e2st = sprintf "%.3f", $end2;
	my $e3st = sprintf "%.3f", $end3;
	
	print "<td><h3>$hstr</h3></td>";
	print "<td><h3>$cstr</h3></td>";
	print "<td><h3>$e3st</h3></td>";
	print "<td><h3>$e2st</h3></td>";
	print "<td><h3>$e1st</h3></td></tr>\n";
}
print "</table>\n";

# BLUE
print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><th colspan=7><h2>Blue Alliance</h2></th></tr>\n";
print "<tr><th>Team</th><th>OPR</th>";
print "<th>Avg. #Hatches</th><th>Avg. #Cargo</th>";
print "<th>Avg Lvl 3</th><th>Avg Lvl 2</th><th>Avg Lvl 1</th></tr>\n";

my $bluetotal = 0;
for (my $i = 0; $i < 3; $i++) {
	my $opr   = $teamScore{$blue[$i]} / $teamCount{$blue[$i]};
	my $hatch = $teamHatch{$blue[$i]} / $teamCount{$blue[$i]};
	my $cargo = $teamCargo{$blue[$i]} / $teamCount{$blue[$i]};
	my $end1  = $teamEnd1{$blue[$i]} / $teamCount{$blue[$i]};
	my $end2  = $teamEnd2{$blue[$i]} / $teamCount{$blue[$i]};
	my $end3  = $teamEnd3{$blue[$i]} / $teamCount{$blue[$i]};
	$bluetotal += $opr;
	my $ostr = sprintf "%.3f", $opr;
	print "<tr><td><h2>";
	print "<a href=\"team.cgi?team=$blue[$i]&event=$event\">$blue[$i]</a></h2></td>";
	print "<td><h2>$ostr</h2></td>";
	my $hstr = sprintf "%.3f", $hatch;
	my $cstr = sprintf "%.3f", $cargo;
	my $e1st = sprintf "%.3f", $end1;
	my $e2st = sprintf "%.3f", $end2;
	my $e3st = sprintf "%.3f", $end3;
	
	print "<td><h3>$hstr</h3></td>";
	print "<td><h3>$cstr</h3></td>";
	print "<td><h3>$e3st</h3></td>";
	print "<td><h3>$e2st</h3></td>";
	print "<td><h3>$e1st</h3></td></tr>\n";
}
print "</table>\n";

my $rt = sprintf "%.1f", $redtotal;
my $bt = sprintf "%.1f", $bluetotal;
print "<h2>Red Alliance Score: $rt</h2>\n";
print "<h2>Blue Alliance Score: $bt</h2>\n";

print "</body></html>\n";