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
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
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
my $file = "/var/www/html/csv/${event}.txt";
if (! -f $file) {
    print "<H2>Error, file $file does not exist</H2>\n";
    print "</body></html>\n";
    exit 0;
}

my %teamScore;
my %teamAuto;
my %teamTeleop;
my %teamCtrl;
my %teamEnd;
my %teamCount;

my %teamALine;
my %teamAIPort;
my %teamAOPort;
my %teamABPort;
my %teamTIPort;
my %teamTOPort;
my %teamTBPort;
my %teamAMissd;
my %teamTMissd;
my %teamRotate;
my %teamPosition;
my %teamPark;
my %teamClimb;
my %teamLevel;


if ( open(my $fh, "<", $file) ) {
    while (my $line = <$fh>) {
	my @items = split /,/, $line;
	next if (@items < 6 || $items[0] eq "event");
	my $team = $items[2];
	my $ALin = int $items[3];
	my $ABot = int $items[4];
	my $AOut = int $items[5];
	my $AInn = int $items[6];
	my $TBot = int $items[7];
	my $TOut = int $items[8];
	my $TInn = int $items[9];
	my $amis = int $items[10];
	my $tmis = int $items[11];
	my $RotC = int $items[37];
	my $PosC = int $items[38];
	my $park = int $items[39];
	my $clim = int $items[40];
	my $levl = int $items[43];
	
	$teamScore{$team}  = 0 unless (defined $teamScore{$team});
	$teamAuto{$team}   = 0 unless (defined $teamAuto{$team});
	$teamTeleop{$team} = 0 unless (defined $teamTeleop{$team});
	$teamCtrl{$team}   = 0 unless (defined $teamCtrl{$team});
	$teamEnd{$team}    = 0 unless (defined $teamEnd{$team});

	$teamALine{$team}  = 0 unless (defined $teamALine{$team});
	$teamABPort{$team} = 0 unless (defined $teamABPort{$team});
	$teamAOPort{$team} = 0 unless (defined $teamAOPort{$team});
	$teamAIPort{$team} = 0 unless (defined $teamAIPort{$team});
	$teamTBPort{$team} = 0 unless (defined $teamTBPort{$team});
	$teamTOPort{$team} = 0 unless (defined $teamTOPort{$team});
	$teamTIPort{$team} = 0 unless (defined $teamTIPort{$team});
	$teamAMissd{$team} = 0 unless (defined $teamAMissd{$team});
	$teamTMissd{$team} = 0 unless (defined $teamTMissd{$team});
	$teamRotate{$team} = 0 unless (defined $teamRotate{$team});
	$teamPosition{$team} = 0 unless (defined $teamPosition{$team});
	$teamPark{$team}   = 0 unless (defined $teamPark{$team});
	$teamClimb{$team}  = 0 unless (defined $teamClimb{$team});
	$teamLevel{$team}  = 0 unless (defined $teamLevel{$team});

        $teamALine{$team}  += $ALin;
	$teamABPort{$team} += $ABot;
	$teamAOPort{$team} += $AOut;
	$teamAIPort{$team} += $AInn;
	$teamTBPort{$team} += $TBot;
	$teamTOPort{$team} += $TOut;
	$teamTIPort{$team} += $TInn;
	$teamAMissd{$team} += $amis;
	$teamTMissd{$team} += $tmis;
	$teamRotate{$team} += $RotC;
	$teamPosition{$team} += $PosC;
	$teamPark{$team}   += $park;
	$teamClimb{$team}  += $clim;
	$teamLevel{$team}  += $levl;
	
	my $auto = ($ALin * 5) + ($ABot * 2) + ($AOut * 4) + ($AInn * 6);
	my $tele = $TBot + ($TOut * 2) + ($TInn * 3);
	my $ctrl = ($RotC * 10) + ($PosC * 20);
	my $endp = ($park * 5) + ($clim * 25) + ($levl * 15);
	$teamAuto{$team} += $auto;
	$teamTeleop{$team} += $tele;
	$teamCtrl{$team} += $ctrl;
	$teamEnd{$team} += $endp;

	$teamScore{$team} += $auto + $tele + $ctrl + $endp;
	
	if (defined $teamCount{$team}) {
	    $teamCount{$team} += 1;
	} else {
	    $teamCount{$team} = 1;
	}
    }
    close $fh;
} else {
    print "<H2>Error, could not open $file: $!</H2>\n";
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

# RED
print "<table cellpadding=2 cellspacing=2 border=1>\n";
print "<tr><th colspan=7><p style=\"font-size:25px; font-weight:bold;\">Red Alliance</p></th></tr>\n";
print "<tr><th>Team</TH><TH># Matches</TH><th>OPR</TH>";
print "<TH>Avg. Auto Score</TH><TH>Avg. TeleOp Score</TH>";
print "<TH>Avg Ctrl Score</TH><TH>Avg End Game</TH></tr>\n";

# gather red high scores
my $hopr  = 0;
my $hauto = 0;
my $htele = 0;
my $hctrl = 0;
my $hend  = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$red[$i]} / $teamCount{$red[$i]};
    my $auto = $teamAuto{$red[$i]} / $teamCount{$red[$i]};
    my $tele = $teamTeleop{$red[$i]} / $teamCount{$red[$i]};
    my $ctrl = $teamCtrl{$red[$i]} / $teamCount{$red[$i]};
    my $endp = $teamEnd{$red[$i]} / $teamCount{$red[$i]};
    $hopr  = $opr  if ($opr > $hopr);
    $hauto = $auto if ($auto > $hauto);
    $htele = $tele if ($tele > $htele);
    $hctrl = $ctrl if ($ctrl > $hctrl);
    $hend  = $endp if ($endp > $hend);
}

my $redtotal = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$red[$i]} / $teamCount{$red[$i]};
    my $auto = $teamAuto{$red[$i]} / $teamCount{$red[$i]};
    my $tele = $teamTeleop{$red[$i]} / $teamCount{$red[$i]};
    my $ctrl = $teamCtrl{$red[$i]} / $teamCount{$red[$i]};
    my $endp = $teamEnd{$red[$i]} / $teamCount{$red[$i]};

    $redtotal += $opr;

    my $ostr = sprintf "%.3f", $opr;
    my $astr = sprintf "%.3f", $auto;
    my $tstr = sprintf "%.3f", $tele;
    my $cstr = sprintf "%.3f", $ctrl;
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
    $bgcolor="bgcolor=\"$green\"" if ($hctrl == $ctrl);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$cstr</p></td>";
    $bgcolor="";
    $bgcolor="bgcolor=\"$green\"" if ($hend == $endp);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$estr</p></td></tr>";
}
print "</table>\n";

# BLUE
print "<table cellpadding=2 cellspacing=2 border=1>\n";
print "<tr><th colspan=7><p style=\"font-size:25px; font-weight:bold;\">Blue Alliance</p></th></tr>\n";
print "<tr><th>Team</TH><TH># Matches</TH><th>OPR</TH>";
print "<TH>Avg. Auto Score</TH><TH>Avg. TeleOp Score</TH>";
print "<TH>Avg Ctrl Score</TH><TH>Avg End game</TH></tr>\n";

# gather blue high scores
$hopr  = 0;
$hauto = 0;
$htele = 0;
$hctrl = 0;
$hend  = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$blue[$i]} / $teamCount{$blue[$i]};
    my $auto = $teamAuto{$blue[$i]} / $teamCount{$blue[$i]};
    my $tele = $teamTeleop{$blue[$i]} / $teamCount{$blue[$i]};
    my $ctrl = $teamCtrl{$blue[$i]} / $teamCount{$blue[$i]};
    my $endp = $teamEnd{$blue[$i]} / $teamCount{$blue[$i]};
    $hopr  = $opr  if ($opr > $hopr);
    $hauto = $auto if ($auto > $hauto);
    $htele = $tele if ($tele > $htele);
    $hctrl = $ctrl if ($ctrl > $hctrl);
    $hend  = $endp if ($endp > $hend);
}

my $bluetotal = 0;
for (my $i = 0; $i < 3; $i++) {
    my $opr  = $teamScore{$blue[$i]} / $teamCount{$blue[$i]};
    my $auto = $teamAuto{$blue[$i]} / $teamCount{$blue[$i]};
    my $tele = $teamTeleop{$blue[$i]} / $teamCount{$blue[$i]};
    my $ctrl = $teamCtrl{$blue[$i]} / $teamCount{$blue[$i]};
    my $endp = $teamEnd{$blue[$i]} / $teamCount{$blue[$i]};

    $bluetotal += $opr;
    my $ostr = sprintf "%.3f", $opr;
    my $astr = sprintf "%.3f", $auto;
    my $tstr = sprintf "%.3f", $tele;
    my $cstr = sprintf "%.3f", $ctrl;
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
    $bgcolor="bgcolor=\"$green\"" if ($hctrl == $ctrl);
    print "<td $bgcolor><p style=\"font-size:20px; font-weight:bold;\">$cstr</p></td>";
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
print "<th colspan=17 align=center>Red Alliance Counters</th>\n";
print "</tr><tr>\n";
print "<th rowspan=2>Team</th><th colspan=5>Avg # Auto</th><th>&nbsp;</th><th colspan=4>Avg # TeleOp</th>";
print "<th rowspan=2>&nbsp;</th><th rowspan=2>Avg #<br>Rota</th><th rowspan=2>Avg #<br>Posi</th>";
print "<th rowspan=2>Avg #<br>Park</th><th rowspan=2>Avg #<br>Climb</th><th rowspan=2>Avg #<br>Level</th>";
print "</tr><tr>\n";
print "<th>Line</th><th>Innr</th><th>Outr</th><th>Botm</th><th>Miss</th>";
print "<th>&nbsp;</th>";
print "<th>Innr</th><th>Outr</th><th>Botm</th><th>Miss</th>\n";
print "</tr>\n";

for (my $i = 0; $i < 3; $i++) {
    my $alin = $teamALine{$red[$i]} / $teamCount{$red[$i]};
    my $ainn = $teamAIPort{$red[$i]} / $teamCount{$red[$i]};
    my $aout = $teamAOPort{$red[$i]} / $teamCount{$red[$i]};
    my $abot = $teamABPort{$red[$i]} / $teamCount{$red[$i]};
    my $tinn = $teamTIPort{$red[$i]} / $teamCount{$red[$i]};
    my $tout = $teamTOPort{$red[$i]} / $teamCount{$red[$i]};
    my $tbot = $teamTBPort{$red[$i]} / $teamCount{$red[$i]};
    my $amis = $teamAMissd{$red[$i]} / $teamCount{$red[$i]};
    my $tmis = $teamTMissd{$red[$i]} / $teamCount{$red[$i]};
    my $rotc = $teamRotate{$red[$i]} / $teamCount{$red[$i]};
    my $posc = $teamPosition{$red[$i]} / $teamCount{$red[$i]};
    my $park = $teamPark{$red[$i]} / $teamCount{$red[$i]};
    my $clim = $teamClimb{$red[$i]} / $teamCount{$red[$i]};
    my $levl = $teamLevel{$red[$i]} / $teamCount{$red[$i]};
        
    my $a = sprintf "%.2f", $alin;
    my $b = sprintf "%.2f", $ainn;
    my $c = sprintf "%.2f", $aout;
    my $d = sprintf "%.2f", $abot;
    my $e = sprintf "%.2f", $amis;
    my $f = sprintf "%.2f", $tinn;
    my $g = sprintf "%.2f", $tout;
    my $h = sprintf "%.2f", $tbot;
    my $j = sprintf "%.2f", $tmis;
    my $k = sprintf "%.2f", $rotc;
    my $l = sprintf "%.2f", $posc;
    my $m = sprintf "%.2f", $park;
    my $n = sprintf "%.2f", $clim;
    my $o = sprintf "%.2f", $levl;
    $a = "&nbsp;" if ($teamALine{$red[$i]} == 0);
    $b = "&nbsp;" if ($teamAIPort{$red[$i]} == 0);
    $c = "&nbsp;" if ($teamAOPort{$red[$i]} == 0);
    $d = "&nbsp;" if ($teamABPort{$red[$i]} == 0);
    $e = "&nbsp;" if ($teamAMissd{$red[$i]} == 0);
    $f = "&nbsp;" if ($teamTIPort{$red[$i]} == 0);
    $g = "&nbsp;" if ($teamTOPort{$red[$i]} == 0);
    $h = "&nbsp;" if ($teamTBPort{$red[$i]} == 0);
    $j = "&nbsp;" if ($teamTMissd{$red[$i]} == 0);
    $k = "&nbsp;" if ($teamRotate{$red[$i]} == 0);
    $l = "&nbsp;" if ($teamPosition{$red[$i]} == 0);
    $m = "&nbsp;" if ($teamPark{$red[$i]} == 0);
    $n = "&nbsp;" if ($teamClimb{$red[$i]} == 0);
    $o = "&nbsp;" if ($teamLevel{$red[$i]} == 0);
    
    print "<tr><th>$red[$i]</th>";
    print "<td>$a</td><td>$b</td><td>$c</td><td>$d</td><td>$e</td>";
    print "<td>&nbsp;</td><td>$f</td><td>$g</td><td>$h</td><td>$j</td><td>&nbsp;</td>";
    print "<td>$k</td><td>$l</td><td>$m</td><td>$n</td><td>$o</td></tr>";
}
print "</table><br>";

print "<table cellpadding=3 border=1><tr>\n";
print "<th colspan=17 align=center>Blue Alliance Counters</th>\n";
print "</tr><tr>\n";
print "<th rowspan=2>Team</th><th colspan=5>Avg # Auto</th><th>&nbsp;</th><th colspan=4>Avg # TeleOp</th>";
print "<th rowspan=2>&nbsp;</th><th rowspan=2>Avg #<br>Rota</th><th rowspan=2>Avg #<br>Posi</th>";
print "<th rowspan=2>Avg #<br>Park</th><th rowspan=2>Avg #<br>Climb</th><th rowspan=2>Avg #<br>Level</th>";
print "</tr><tr>\n";
print "<th>Line</th><th>Innr</th><th>Outr</th><th>Botm</th><th>Miss</th>";
print "<th>&nbsp;</th>";
print "<th>Innr</th><th>Outr</th><th>Botm</th><th>Miss</th>\n";
print "</tr>\n";

for (my $i = 0; $i < 3; $i++) {
    my $alin = $teamALine{$blue[$i]} / $teamCount{$blue[$i]};
    my $ainn = $teamAIPort{$blue[$i]} / $teamCount{$blue[$i]};
    my $aout = $teamAOPort{$blue[$i]} / $teamCount{$blue[$i]};
    my $abot = $teamABPort{$blue[$i]} / $teamCount{$blue[$i]};
    my $tinn = $teamTIPort{$blue[$i]} / $teamCount{$blue[$i]};
    my $tout = $teamTOPort{$blue[$i]} / $teamCount{$blue[$i]};
    my $tbot = $teamTBPort{$blue[$i]} / $teamCount{$blue[$i]};
    my $amis = $teamAMissd{$blue[$i]} / $teamCount{$blue[$i]};
    my $tmis = $teamTMissd{$blue[$i]} / $teamCount{$blue[$i]};
    my $rotc = $teamRotate{$blue[$i]} / $teamCount{$blue[$i]};
    my $posc = $teamPosition{$blue[$i]} / $teamCount{$blue[$i]};
    my $park = $teamPark{$blue[$i]} / $teamCount{$blue[$i]};
    my $clim = $teamClimb{$blue[$i]} / $teamCount{$blue[$i]};
    my $levl = $teamLevel{$blue[$i]} / $teamCount{$blue[$i]};

    my $a = sprintf "%.2f", $alin;
    my $b = sprintf "%.2f", $ainn;
    my $c = sprintf "%.2f", $aout;
    my $d = sprintf "%.2f", $abot;
    my $e = sprintf "%.2f", $amis;
    my $f = sprintf "%.2f", $tinn;
    my $g = sprintf "%.2f", $tout;
    my $h = sprintf "%.2f", $tbot;
    my $j = sprintf "%.2f", $tmis;
    my $k = sprintf "%.2f", $rotc;
    my $l = sprintf "%.2f", $posc;
    my $m = sprintf "%.2f", $park;
    my $n = sprintf "%.2f", $clim;
    my $o = sprintf "%.2f", $levl;
    $a = "&nbsp;" if ($teamALine{$blue[$i]} == 0);
    $b = "&nbsp;" if ($teamAIPort{$blue[$i]} == 0);
    $c = "&nbsp;" if ($teamAOPort{$blue[$i]} == 0);
    $d = "&nbsp;" if ($teamABPort{$blue[$i]} == 0);
    $e = "&nbsp;" if ($teamAMissd{$blue[$i]} == 0);
    $f = "&nbsp;" if ($teamTIPort{$blue[$i]} == 0);
    $g = "&nbsp;" if ($teamTOPort{$blue[$i]} == 0);
    $h = "&nbsp;" if ($teamTBPort{$blue[$i]} == 0);
    $j = "&nbsp;" if ($teamTMissd{$blue[$i]} == 0);
    $k = "&nbsp;" if ($teamRotate{$blue[$i]} == 0);
    $l = "&nbsp;" if ($teamPosition{$blue[$i]} == 0);
    $m = "&nbsp;" if ($teamPark{$blue[$i]} == 0);
    $n = "&nbsp;" if ($teamClimb{$blue[$i]} == 0);
    $o = "&nbsp;" if ($teamLevel{$blue[$i]} == 0);
    
    print "<tr><th>$blue[$i]</th>";
    print "<td>$a</td><td>$b</td><td>$c</td><td>$d</td><td>$e</td>";
    print "<td>&nbsp;</td><td>$f</td><td>$g</td><td>$h</td><td>$j</td><td>&nbsp;</td>";
    print "<td>$k</td><td>$l</td><td>$m</td><td>$n</td><td>$o</td></tr>";
}

print "</table>";
print "</body></html>\n";
