#!/usr/bin/perl -w

use strict;
use warnings;

my $event = "";
my @red;
my @blue;

my $green = "#7ef542";

#
# read in given game data
#
if (exists $ENV{'QUERY_STRING'}) {
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
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";
print "<table cellpadding=2 border=0><tr><td>";
print "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td><th>";
print "<H1>Match Predictor</H1>\n";
print "</th><td>";
print "<p>&nbsp; &nbsp; &nbsp;<a href=\"index.cgi\">Home</a></p>\n";
print "</td></tr></table>\n";
if ($event eq "") {
    print "<H2>Error, need an event</H2>\n";
    print "</body></html>\n";
    exit 0;
}

#
# Load event data
#
my $file = "csv/${event}.txt";
if (! -f $file) {
    print "<H2>Error, file $file does not exist</H2>\n";
    print "</body></html>\n";
    exit 0;
}

my %teamScore;
my %teamAuto;
my %teamTeleop;
my %teamEnd;
my %teamCount;

my %teamTaxi;
my %teamHuman;
my %teamAlo;
my %teamAhi;
my %teamTlo;
my %teamThi;
my %teamRung;

my $fh;
if ( ! open($fh, "<", $file) ) {
    print "<H2>Error, could not open $file: $!</H2>\n";
    print "</body></html>\n";
    exit 0;
}
while (my $line = <$fh>) {
    my @items = split /,/, $line;
    next if (@items < 6 || $items[0] eq "event");
    my $team  = $items[2];
    my $taxi  = int $items[3];
    my $human = int $items[4];
    my $Alo   = int $items[5];
    my $Ahi   = int $items[6];
    my $Tlo   = int $items[9];
    my $Thi   = int $items[10];
    my $rung  = int $items[17];
	
    $teamScore{$team}  = 0 unless (defined $teamScore{$team});
    $teamAuto{$team}   = 0 unless (defined $teamAuto{$team});
    $teamTeleop{$team} = 0 unless (defined $teamTeleop{$team});
    $teamEnd{$team}    = 0 unless (defined $teamEnd{$team});
    
    $teamTaxi{$team}  = 0 unless (defined $teamTaxi{$team});
    $teamHuman{$team} = 0 unless (defined $teamHuman{$team});
    $teamAlo{$team} = 0 unless (defined $teamAlo{$team});
    $teamAhi{$team} = 0 unless (defined $teamAhi{$team});
    $teamTlo{$team} = 0 unless (defined $teamTlo{$team});
    $teamThi{$team} = 0 unless (defined $teamThi{$team});
    $teamRung{$team} = 0 unless (defined $teamRung{$team});
    
    $teamTaxi{$team}  += $taxi;
    $teamHuman{$team} += $human;
    $teamAlo{$team}   += $Alo;
    $teamAhi{$team}   += $Ahi;
    $teamTlo{$team}   += $Tlo;
    $teamThi{$team}   += $Thi;
    $teamRung{$team}  += $rung;
	
    my $auto = ($taxi * 2) + ($Alo * 2) + ($Ahi * 4);
    my $tele = $Tlo + ($Thi * 2);
    my $endp = 0;
    $endp = 4 if ($rung == 1);
    $endp = 6 if ($rung == 2);
    $endp = 10 if ($rung == 3);
    $endp = 15 if ($rung == 4);
    $teamAuto{$team} += $auto;
    $teamTeleop{$team} += $tele;
    $teamEnd{$team} += $endp;

    $teamScore{$team} += $auto + $tele + $endp;
    
    if (defined $teamCount{$team}) {
	$teamCount{$team} += 1;
    } else {
	$teamCount{$team} = 1;
    }
}
close $fh;


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
    print "<FORM ACTION=\"matchup.cgi\">\n";
    print "<INPUT TYPE=\"hidden\" NAME=\"r1\" VALUE=\"$red[0]\">" if (@red > 0);
    print "<INPUT TYPE=\"hidden\" NAME=\"r2\" VALUE=\"$red[1]\">" if (@red > 1);
    print "<INPUT TYPE=\"hidden\" NAME=\"r3\" VALUE=\"$red[2]\">" if (@red > 2);
    print "<INPUT TYPE=\"hidden\" NAME=\"b1\" VALUE=\"$blue[0]\">" if (@blue > 0);
    print "<INPUT TYPE=\"hidden\" NAME=\"b2\" VALUE=\"$blue[1]\">" if (@blue > 1);
    print "<INPUT TYPE=\"hidden\" NAME=\"b3\" VALUE=\"$blue[2]\">" if (@blue > 2);

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
    

    print "<H3>Select ${pos}:</H3>\n";
    my @teams = sort {$a <=> $b} (keys %teamScore);
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

# RED
print "<table cellpadding=2 cellspacing=2 border=1>\n";
print "<tr><th colspan=7><p style=\"font-size:25px; font-weight:bold;\">Red Alliance</p></th></tr>\n";
print "<tr><th>Team</TH><TH># Matches</TH><th>OPR</TH>";
print "<TH>Avg. Auto Score</TH><TH>Avg. TeleOp Score</TH></TH><TH>Avg End Game</TH></tr>\n";

# gather red high scores
my $hopr  = 0;
my $hauto = 0;
my $htele = 0;
my $hend  = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$red[$i]} / $teamCount{$red[$i]};
    my $auto = $teamAuto{$red[$i]} / $teamCount{$red[$i]};
    my $tele = $teamTeleop{$red[$i]} / $teamCount{$red[$i]};
    my $endp = $teamEnd{$red[$i]} / $teamCount{$red[$i]};
    $hopr  = $opr  if ($opr > $hopr);
    $hauto = $auto if ($auto > $hauto);
    $htele = $tele if ($tele > $htele);
    $hend  = $endp if ($endp > $hend);
}

my $redtotal = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$red[$i]} / $teamCount{$red[$i]};
    my $auto = $teamAuto{$red[$i]} / $teamCount{$red[$i]};
    my $tele = $teamTeleop{$red[$i]} / $teamCount{$red[$i]};
    my $endp = $teamEnd{$red[$i]} / $teamCount{$red[$i]};

    $redtotal += $opr;

    my $ostr = sprintf "%.3f", $opr;
    my $astr = sprintf "%.3f", $auto;
    my $tstr = sprintf "%.3f", $tele;
    my $estr = sprintf "%.3f", $endp;

    print "<tr><td><p style=\"font-size:25px; font-weight:bold;\">";
    print "<a href=\"team.cgi?team=$red[$i]&event=$event\">$red[$i]</a></p></td>";
    print "<td><p style=\"font-size:25px; font-weight:bold;\">$teamCount{$red[$i]}</p></td>\n";

    my $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($hopr == $opr);
    print "<td $bgcolor><p style=\"font-size:25px; font-weight:bold;\">$ostr</p></td>";
    $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($hauto == $auto);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$astr</p></td>";
    $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($htele == $tele);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$tstr</p></td>";
    $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($hend == $endp);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$estr</p></td></tr>";
}
print "</table>\n";

# BLUE
print "<table cellpadding=2 cellspacing=2 border=1>\n";
print "<tr><th colspan=7><p style=\"font-size:25px; font-weight:bold;\">Blue Alliance</p></th></tr>\n";
print "<tr><th>Team</TH><TH># Matches</TH><th>OPR</TH>";
print "<TH>Avg. Auto Score</TH><TH>Avg. TeleOp Score</TH><TH>Avg End game</TH></tr>\n";

# gather blue high scores
$hopr  = 0;
$hauto = 0;
$htele = 0;
$hend  = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$blue[$i]} / $teamCount{$blue[$i]};
    my $auto = $teamAuto{$blue[$i]} / $teamCount{$blue[$i]};
    my $tele = $teamTeleop{$blue[$i]} / $teamCount{$blue[$i]};
    my $endp = $teamEnd{$blue[$i]} / $teamCount{$blue[$i]};
    $hopr  = $opr  if ($opr > $hopr);
    $hauto = $auto if ($auto > $hauto);
    $htele = $tele if ($tele > $htele);
    $hend  = $endp if ($endp > $hend);
}

my $bluetotal = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$blue[$i]} / $teamCount{$blue[$i]};
    my $auto = $teamAuto{$blue[$i]} / $teamCount{$blue[$i]};
    my $tele = $teamTeleop{$blue[$i]} / $teamCount{$blue[$i]};
    my $endp = $teamEnd{$blue[$i]} / $teamCount{$blue[$i]};

    $bluetotal += $opr;
    my $ostr = sprintf "%.3f", $opr;
    my $astr = sprintf "%.3f", $auto;
    my $tstr = sprintf "%.3f", $tele;
    my $estr = sprintf "%.3f", $endp;
    
    print "<tr><td><p style=\"font-size:25px; font-weight:bold;\">";
    print "<a href=\"team.cgi?team=$blue[$i]&event=$event\">$blue[$i]</a></p></td>";
    print "<td><p style=\"font-size:25px; font-weight:bold;\">$teamCount{$blue[$i]}</p></td>\n";
    
    my $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($hopr == $opr);
    print "<td $bgcolor><p style=\"font-size:25px; font-weight:bold;\">$ostr</p></td>";
    $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($hauto == $auto);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$astr</p></td>";
    $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($htele == $tele);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$tstr</p></td>";
    $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($hend == $endp);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$estr</p></td></tr>\n";
}
print "</table>\n";

my $rt = sprintf "%.1f", $redtotal;
my $bt = sprintf "%.1f", $bluetotal;
print "<table cellpadding=3 border=0><tr><td>";
print "<p style=\"font-size: 25px; font-weight:bold;\">Red Alliance Score: $rt</p>\n";
print "</td><td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </td><td>";
print "<p style=\"font-size: 25px; font-weight:bold;\">Blue Alliance Score: $bt</p>\n";
print "</td></tr></table>\n";
print "<br>\n";
# print details
print "<table cellpadding=3 border=1><tr>\n";
print "<th colspan=11 align=center>Red Alliance Counters</th>\n";
print "</tr><tr>\n";
print "<th rowspan=2>Team</th><th colspan=4>Avg # Auto</th><th rowspan=2>&nbsp;</th>";
print "<th colspan=2>Avg # TeleOp</th><th rowspan=2>&nbsp;</th><th rowspan=2>Avg #<br>Rungs</th>";
print "</tr><tr>\n";
print "<th>Taxi</th><th>Human</th><th>Low</th><th>High</th>";
print "<th>Low</th><th>High</th>\n";
print "</tr>\n";

for (my $i = 0; $i < 3; $i++) {
    my $taxi  = $teamTaxi{$red[$i]} / $teamCount{$red[$i]};
    my $human = $teamHuman{$red[$i]} / $teamCount{$red[$i]};
    my $alo   = $teamAlo{$red[$i]} / $teamCount{$red[$i]};
    my $ahi   = $teamAhi{$red[$i]} / $teamCount{$red[$i]};
    my $tlo   = $teamTlo{$red[$i]} / $teamCount{$red[$i]};
    my $thi   = $teamThi{$red[$i]} / $teamCount{$red[$i]};
    my $rung  = $teamRung{$red[$i]} / $teamCount{$red[$i]};
        
    my $a = sprintf "%.2f", $taxi;
    my $b = sprintf "%.2f", $human;
    my $c = sprintf "%.2f", $alo;
    my $d = sprintf "%.2f", $ahi;
    my $e = sprintf "%.2f", $tlo;
    my $f = sprintf "%.2f", $thi;
    my $g = sprintf "%.2f", $rung;
    $a = "&nbsp;" if ($teamTaxi{$red[$i]} == 0);
    $b = "&nbsp;" if ($teamHuman{$red[$i]} == 0);
    $c = "&nbsp;" if ($teamAlo{$red[$i]} == 0);
    $d = "&nbsp;" if ($teamAhi{$red[$i]} == 0);
    $e = "&nbsp;" if ($teamTlo{$red[$i]} == 0);
    $f = "&nbsp;" if ($teamThi{$red[$i]} == 0);
    $g = "&nbsp;" if ($teamRung{$red[$i]} == 0);
    
    print "<tr><th>$red[$i]</th>";
    print "<td>$a</td><td>$b</td><td>$c</td><td>$d</td>";
    print "<td>&nbsp;</td><td>$e</td><td>$f</td><td>&nbsp;</td><td>$g</td></tr>";
}
print "</table><br>";

print "<table cellpadding=3 border=1><tr>\n";
print "<th colspan=11 align=center>Blue Alliance Counters</th>\n";
print "</tr><tr>\n";
print "<th rowspan=2>Team</th><th colspan=4>Avg # Auto</th><th rowspan=2>&nbsp;</th>";
print "<th colspan=2>Avg # TeleOp</th><th rowspan=2>&nbsp;</th><th rowspan=2>Avg #<br>Rungs</th>";
print "</tr><tr>\n";
print "<th>Taxi</th><th>Human</th><th>Low</th><th>high</th>";
print "<th>Low</th><th>High</th>";
print "</tr>\n";

for (my $i = 0; $i < 3; $i++) {
    my $taxi  = $teamTaxi{$blue[$i]} / $teamCount{$blue[$i]};
    my $human = $teamHuman{$blue[$i]} / $teamCount{$blue[$i]};
    my $alo   = $teamAlo{$blue[$i]} / $teamCount{$blue[$i]};
    my $ahi   = $teamAhi{$blue[$i]} / $teamCount{$blue[$i]};
    my $tlo   = $teamTlo{$blue[$i]} / $teamCount{$blue[$i]};
    my $thi   = $teamThi{$blue[$i]} / $teamCount{$blue[$i]};
    my $rung  = $teamRung{$blue[$i]} / $teamCount{$blue[$i]};

    my $a = sprintf "%.2f", $taxi;
    my $b = sprintf "%.2f", $human;
    my $c = sprintf "%.2f", $alo;
    my $d = sprintf "%.2f", $ahi;
    my $e = sprintf "%.2f", $tlo;
    my $f = sprintf "%.2f", $thi;
    my $g = sprintf "%.2f", $rung;
    $a = "&nbsp;" if ($teamTaxi{$blue[$i]} == 0);
    $b = "&nbsp;" if ($teamHuman{$blue[$i]} == 0);
    $c = "&nbsp;" if ($teamAlo{$blue[$i]} == 0);
    $d = "&nbsp;" if ($teamAhi{$blue[$i]} == 0);
    $e = "&nbsp;" if ($teamTlo{$blue[$i]} == 0);
    $f = "&nbsp;" if ($teamThi{$blue[$i]} == 0);
    $g = "&nbsp;" if ($teamRung{$blue[$i]} == 0);
    
    print "<tr><th>$blue[$i]</th>";
    print "<td>$a</td><td>$b</td><td>$c</td><td>$d</td>";
    print "<td>&nbsp;</td><td>$e</td><td>$f</td><td>&nbsp;</td><td>$g</td></tr>";
}

print "</table>";
print "</body></html>\n";
