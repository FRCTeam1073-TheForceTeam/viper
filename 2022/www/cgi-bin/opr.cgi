#!/usr/bin/perl

use strict;
use warnings;

my $green = "#7ef542";
my $event = "";

my $TEAMS = "/var/www/cgi-bin/teams.txt";
#
# read in given game data
#
if ($ENV{'QUERY_STRING'}) {
    my @args = split /\&/, $ENV{'QUERY_STRING'};
    my %params;
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
    $event = $params{'event'}  if (defined $params{'event'});
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<!DOCTYPE html>\n";
print "<html lang=\"en\">\n";
print "<head>\n";
print "  <meta charset=\"utf-8\"/>\n";
print "  <title>FRC Scouting App</title>\n";
print "  <style>\n";
print "    #overlay {\n";
print "      position: fixed;\n";
print "      display: none;\n";
print "      width: 100%;\n";
print "      height: 100%;\n";
print "      top: 0;\n";
print "      left: 0;\n";
print "      right: 0;\n";
print "      bottom: 0;\n";
print "      background-color: rgba(0,0,0,0.9);\n";
print "      z-index: 2;\n";
print "      cursor: pointer;\n";
print "    }\n";
print "    #text {\n";
print "      position: absolute;\n";
print "      top: 50%;\n";
print "      left: 50%;\n";
print "      color: white;\n";
print "      transform: translate(-50%,-50%);\n";
print "     -ms-transform: translate(-50%,-50%);\n";
print "    }\n";
print "    #span {\n";
print "      text-decoration: underline;\n";
print "    }\n";
print "  </style>\n";
print "</head>\n";
print "<body bgcolor=\"#eeeeee\"><center>\n";

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
my %teamCount;

my %teamTaxi;
my %teamHuman;
my %teamAlo;
my %teamAhi;
my %teamAmis;
my %teamAbnc;
my %teamTlo;
my %teamThi;
my %teamTmis;
my %teamTbnc;
my %teamTRung;
my %teamHRung;
my %teamMRung;
my %teamLRung;
my %teamOverlayT1;
my %teamOverlayT2;
my %teamOverlayT3;


sub parseStr($) {
    my ($str) = (@_);
    # substr parsing before per-character parsing
    # %2C = ,
    $str =~ s/%2C/_/g;
    # %27 = '
    $str =~ s/%27//g;
    # %21 = !
    $str =~ s/%21//g;
    # %25 = %
    $str =~ s/%25/%/g;
    my @bits = split "", $str;
    my $count = 0;
    my @final;
    my $space = 0;
    foreach my $c (@bits) {
	if ($c =~ /[a-zA-Z0-9-=\.%_]/) {
	    push @final, $c;
	    $space = 0;
	} else {
	    if ($space == 0) {
		push @final, ' ';
		$space = 1;
	    }
	}
	$count++;
	if ($count > 75 && $space == 1) {
	    push @final, '<br>';
	    $count = 0;
	}
    }
    if (@final > 0) {
	my $result = join "", @final;
	return $result;
    }
    return "";
}


my $fh;

# first load team Name info
my %teamName;
if ( -f "$TEAMS" ) {
    if (open($fh, "<", $TEAMS)) {
	while (my $line = <$fh>) {
	    my @items = split/:/, $line;
	    next unless (@items == 3);
	    my $num = $items[0];
	    $teamName{$num} = $items[1];
	}
	close $fh;
    }
}

# now process scouting data
if ( ! open($fh, "<", $file) ) {
    print "<H2>Error, could not open $file: $!</H2>\n";
    print "</body></html>\n";
    exit 0;
}
while (my $line = <$fh>) {
    my @items = split /,/, $line;
    next if (@items < 6 || $items[0] eq "event");
    my $match  = $items[1];
    my $team   = $items[2];
    my $taxi   = $items[3];
    my $human  = $items[4];
    my $Alo    = $items[5];
    my $Ahi    = $items[6];
    my $Amis   = $items[7];
    my $Abnc   = $items[8];
    my $Tlo    = $items[9];
    my $Thi    = $items[10];
    my $Tmis   = $items[11];
    my $Tbnc   = $items[12];
    my $rung   = $items[17];

    if (! exists $teamOverlayT1{$team}) {
	$teamOverlayT1{$team}  = "<H3>Click/Tap screen to go back</H3><br>";
	$teamOverlayT1{$team} .= "<table cellspacing=0 cellpadding=5 border=1><tr>";
	$teamOverlayT1{$team} .= "<th colspan=12 align=center><font size=+2>$team";
	$teamOverlayT1{$team} .= "&nbsp;$teamName{$team}" if (exists $teamName{$team});
	$teamOverlayT1{$team} .= "</font></th></tr><tr>";
	$teamOverlayT1{$team} .= "<th>Match</th><th>Taxi</th><th>Human</th>";
	$teamOverlayT1{$team} .= "<th>Auto<br>Lower</th><th>Auto<br>Upper</th>";
	$teamOverlayT1{$team} .= "<th>TeleOp<br>Lower</th><th>TeleOp<br>Upper</th>";
	$teamOverlayT1{$team} .= "<th>Shoot<br>From<br>Hub</th><th>Shoot<br>From<br>Field</th>";
	$teamOverlayT1{$team} .= "<th>Shoot<br>Outer<br>LnchPad</th><th>Shoot<br>Wall<br>LnchPad</th>";
	$teamOverlayT1{$team} .= "<th>EndGame<br>Rung</th></tr>";
    }
    $teamOverlayT1{$team} .= "<tr><td align=center>$match</td><td align=center>$taxi</td><td align=center>$human</td>";
    $teamOverlayT1{$team} .= "<td align=center>$Alo</td><td align=center>$Ahi</td><td align=center>$Tlo</td>";
    my $a1 = "No";
    $a1 = 'Yes' if ("$items[13]" ne "0");
    my $a2 = "No";
    $a2 = 'Yes' if ("$items[14]" ne "0");
    $teamOverlayT1{$team} .= "<td align=center>$Thi</td><td align=center>$a1</td><td align=center>$a2</td>";
    $a1 = "No";
    $a1 = 'Yes' if ("$items[15]" ne "0");
    $a2 = "No";
    $a2 = 'Yes' if ("$items[16]" ne "0");
    my $a3 = "None";
    $a3 = 'Low' if ("$rung" eq "1");
    $a3 = 'Middle' if ("$rung" eq "2");
    $a3 = 'high' if ("$rung" eq "3");
    $a3 = 'Traversal' if ("$rung" eq "4");
    $teamOverlayT1{$team} .= "<td align=center>$a1</td><td align=center>$a2</td><td align=center>$a3</td></tr>";

    if (! exists $teamOverlayT2{$team}) {
	$teamOverlayT2{$team}  = "<table cellspacing=0 cellpadding=5 border=1><tr>";
	$teamOverlayT2{$team} .= "<th>Match</th><th>Auto<br>Miss</th><th>TeleOp<br>Miss</th>";
	$teamOverlayT2{$team} .= "<th>Auto<br>Bounce</th><th>TeleOp<br>Bounce</th>";
	$teamOverlayT2{$team} .= "<th align=center>Played<br>Defense</th><th align=center>Against<br>Defense</th>";
	$teamOverlayT2{$team} .= "<th>Fouls</th><th>Tech<br>Fouls</th><th align=center>Rank</th></tr>";
    }
    $teamOverlayT2{$team} .= "<tr><td align=center>$match</td><td align=center>$Amis</td><td align=center>$Tmis</td>";
    $teamOverlayT2{$team} .= "<td align=center>$Abnc</td><td align=center>$Tbnc</td>";
    $a1 = 'None';
    $a1 = 'Minimal' if ("$items[18]" eq "1");
    $a1 = 'Average' if ("$items[18]" eq "2");
    $a1 = 'Good' if ("$items[18]" eq "3");
    $a2 = 'None';
    $a2 = 'Affected' if ("$items[19]" eq "1");
    $a2 = 'Average' if ("$items[19]" eq "2");
    $a2 = 'Unaffected' if ("$items[19]" eq "3");
    $teamOverlayT2{$team} .= "<td align=center>$a1</td><td align=center>$a2</td>";
    $teamOverlayT2{$team} .= "<td align=center>$items[20]</td><td align=center>$items[21]</td>";
    $a1 = 'None';
    $a1 = 'Struggled' if ("$items[22]" eq "1");
    $a1 = 'Decent' if ("$items[22]" eq "2");
    $a1 = 'Very Good' if ("$items[22]" eq "3");
    $teamOverlayT2{$team} .= "<td align=center>$a1</td></tr>";

    if (! exists $teamOverlayT3{$team}) {
	$teamOverlayT3{$team}  = "<table cellspacing=0 cellpadding=5 border=1><tr>";
	$teamOverlayT3{$team} .= "<th>Match</th><th align=center>Scouter</th><th>Comments</th></tr><tr>";
    }
    $a1 = parseStr("$items[23]");
    $a2 = parseStr("$items[24]");
    $teamOverlayT3{$team} .= "<td>$match</td><td>$a1</td><td>$a2</td></tr>";

    # missing initiation line and end game scoring
    $teamScore{$team}  = 0 unless (defined $teamScore{$team});
    $teamTaxi{$team}  = 0 unless (defined $teamTaxi{$team});
    $teamHuman{$team} = 0 unless (defined $teamHuman{$team});
    $teamAlo{$team} = 0 unless (defined $teamAlo{$team});
    $teamAhi{$team} = 0 unless (defined $teamAhi{$team});
    $teamAmis{$team} = 0 unless (defined $teamAmis{$team});
    $teamAbnc{$team} = 0 unless (defined $teamAbnc{$team});
    $teamTlo{$team} = 0 unless (defined $teamTlo{$team});
    $teamThi{$team} = 0 unless (defined $teamThi{$team});
    $teamTmis{$team} = 0 unless (defined $teamTmis{$team});
    $teamTbnc{$team} = 0 unless (defined $teamTbnc{$team});
    $teamTRung{$team} = 0 unless (defined $teamTRung{$team});
    $teamHRung{$team} = 0 unless (defined $teamHRung{$team});
    $teamMRung{$team} = 0 unless (defined $teamMRung{$team});
    $teamLRung{$team} = 0 unless (defined $teamLRung{$team});
    
    $teamTaxi{$team}  += $taxi;
    $teamHuman{$team} += $human;
    $teamAlo{$team} += $Alo;
    $teamAhi{$team} += $Ahi;
    $teamAmis{$team} += $Amis;
    $teamAbnc{$team} += $Abnc;
    $teamTlo{$team} += $Tlo;
    $teamThi{$team} += $Thi;
    $teamTmis{$team} += $Tmis;
    $teamTbnc{$team} += $Tbnc;
    $teamTRung{$team} += 1 if ($rung == 4);
    $teamHRung{$team} += 1 if ($rung == 3);
    $teamMRung{$team} += 1 if ($rung == 2);
    $teamLRung{$team} += 1 if ($rung == 1);

    # assuming that the human scores in upper hub during auto
    # UPDATE: T and E say don't add HP points to OPR: "unfair to robot!"
    #my $score = ($taxi * 2) + ($human * 4) + ($Alo * 2) + ($Ahi * 4);
    my $score = ($taxi * 2) + ($Alo * 2) + ($Ahi * 4);
    $score += $Tlo + ($Thi * 2);
    $score += 4  if ($rung == 1);
    $score += 6  if ($rung == 2);
    $score += 10 if ($rung == 3);
    $score += 15 if ($rung == 4);
    $teamScore{$team} += $score;
    if (defined $teamCount{$team}) {
	$teamCount{$team} += 1;
    } else {
	$teamCount{$team} = 1;
    }
}
close $fh;

#
# compute averages and high scores for each column
#
my %avgOpr;
my %avgTaxi;
my %avgHuman;
my %avgAlo;
my %avgAhi;
my %avgAmis;
my %avgAbnc;
my %avgTlo;
my %avgThi;
my %avgTmis;
my %avgTbnc;
my %avgTRung;
my %avgHRung;
my %avgMRung;
my %avgLRung;

my $highOpr = 0;
my $highTaxi = 0;
my $highHuman = 0;
my $highAlo = 0;
my $highAhi = 0;
my $highAmis = 0;
my $highAbnc = 0;
my $highTlo = 0;
my $highThi = 0;
my $highTmis = 0;
my $highTbnc = 0;
my $highTRung = 0;
my $highHRung = 0;
my $highMRung = 0;
my $highLRung = 0;

# average and add to list
foreach my $k (keys %teamScore) {

    $avgOpr{$k}   = $teamScore{$k} / $teamCount{$k};
    $avgTaxi{$k}  = $teamTaxi{$k} / $teamCount{$k};
    $avgHuman{$k} = $teamHuman{$k} / $teamCount{$k};
    $avgAlo{$k}   = $teamAlo{$k} / $teamCount{$k};
    $avgAhi{$k}   = $teamAhi{$k} / $teamCount{$k};
    $avgAmis{$k}  = $teamAmis{$k} / $teamCount{$k};
    $avgAbnc{$k}  = $teamAbnc{$k} / $teamCount{$k};
    $avgTlo{$k}   = $teamTlo{$k} / $teamCount{$k};
    $avgThi{$k}   = $teamThi{$k} / $teamCount{$k};
    $avgTmis{$k}  = $teamTmis{$k} / $teamCount{$k};
    $avgTbnc{$k}  = $teamTbnc{$k} / $teamCount{$k};
    $avgTRung{$k} = $teamTRung{$k} / $teamCount{$k};
    $avgHRung{$k} = $teamHRung{$k} / $teamCount{$k};
    $avgMRung{$k} = $teamMRung{$k} / $teamCount{$k};
    $avgLRung{$k} = $teamLRung{$k} / $teamCount{$k};
    
    $highOpr   = $avgOpr{$k} if ($avgOpr{$k} > $highOpr);
    $highTaxi  = $avgTaxi{$k} if ($avgTaxi{$k} > $highTaxi);
    $highHuman = $avgHuman{$k} if ($avgHuman{$k} > $highHuman);
    $highAlo   = $avgAlo{$k} if ($avgAlo{$k} > $highAlo);
    $highAhi   = $avgAhi{$k} if ($avgAhi{$k} > $highAhi);
    $highAmis  = $avgAmis{$k} if ($avgAmis{$k} > $highAmis);
    $highAbnc  = $avgAbnc{$k} if ($avgAbnc{$k} > $highAbnc);
    $highTlo   = $avgTlo{$k} if ($avgTlo{$k} > $highTlo);
    $highThi   = $avgThi{$k} if ($avgThi{$k} > $highThi);
    $highTmis  = $avgTmis{$k} if ($avgTmis{$k} > $highTmis);
    $highTbnc  = $avgTbnc{$k} if ($avgTbnc{$k} > $highTbnc);
    $highTRung = $avgTRung{$k} if ($avgTRung{$k} > $highTRung);
    $highHRung = $avgHRung{$k} if ($avgHRung{$k} > $highHRung);
    $highMRung = $avgMRung{$k} if ($avgMRung{$k} > $highMRung);
    $highLRung = $avgLRung{$k} if ($avgLRung{$k} > $highLRung);
}

# assign JS data variables @teams, @metrics, and %teamdata
my @teams = keys %teamScore;
# opr is in the %teamdata but not listed in the metrics
# metric sort falls back on opr when metric values match
# metrics here are in the order in which they will be listed
my @metrics = ('human', 'taxi', 'alo', 'ahi', 'tlo', 'thi', 'trung', 'hrung', 'mrung', 'lrung',
	       'amis', 'tmis', 'abnc', 'tbnc');
my %humanStr = (taxi => '<br>Taxied<br>&nbsp;', human => 'Human<BR>Scored*<br>&nbsp;',
		alo => 'Avg #<BR>Auto<BR>Lower', ahi => 'Avg #<BR>Auto<BR>Upper',
		amis => 'Avg #<BR>Auto<BR>Missed', abnc => 'Avg #<BR>Auto<BR>Bounced',
		tlo => 'Avg #<BR>Lower<BR>Cargo', thi => 'Avg #<BR>Upper<BR>Cargo',
		tmis => 'Avg #<BR>Missed<BR>Cargo', tbnc => 'Avg #<BR>Bounced<BR>Cargo',
		trung => 'Traversal<BR>Rung<BR>Reached', hrung => 'High<BR>Rung<BR>Reached',
		mrung => 'Middle<BR>Rung<BR>Reached', lrung => 'Low<BR>Rung<BR>Reached');
my %teamdata;
my %high;
my %printdata;
foreach my $t (@teams) {
    my $k = "${t}opr";
    $teamdata{$k} = sprintf "%.2f", $avgOpr{$t};
    $highOpr = $teamdata{$k} if ($avgOpr{$t} == $highOpr);
    $k = "${t}human";
    $teamdata{$k} = sprintf "%.2f", $avgHuman{$t};
    $printdata{$k} = sprintf "%d/%d", $teamHuman{$t}, $teamCount{$t};
    $high{'human'} = $teamdata{$k} if ($avgHuman{$t} == $highHuman);
    $k = "${t}taxi";
    $teamdata{$k} = sprintf "%.2f", $avgTaxi{$t};
    $printdata{$k} = sprintf "%d/%d", $teamTaxi{$t}, $teamCount{$t};
    $high{'taxi'} = $teamdata{$k} if ($avgTaxi{$t} == $highTaxi);
    $k = "${t}alo";
    $teamdata{$k} = sprintf "%.2f", $avgAlo{$t};
    $high{'alo'} = $teamdata{$k} if ($avgAlo{$t} == $highAlo);
    $k = "${t}ahi";
    $teamdata{$k} = sprintf "%.2f", $avgAhi{$t};
    $high{'ahi'} = $teamdata{$k} if ($avgAhi{$t} == $highAhi);
    $k = "${t}amis";
    $teamdata{$k} = sprintf "%.2f", $avgAmis{$t};
    $high{'amis'} = $teamdata{$k} if ($avgAmis{$t} == $highAmis);
    $k = "${t}abnc";
    $teamdata{$k} = sprintf "%.2f", $avgAbnc{$t};
    $high{'abnc'} = $teamdata{$k} if ($avgAbnc{$t} == $highAbnc);
    $k = "${t}tlo";
    $teamdata{$k} = sprintf "%.2f", $avgTlo{$t};
    $high{'tlo'} = $teamdata{$k} if ($avgTlo{$t} == $highTlo);
    $k = "${t}thi";
    $teamdata{$k} = sprintf "%.2f", $avgThi{$t};
    $high{'thi'} = $teamdata{$k} if ($avgThi{$t} == $highThi);
    $k = "${t}tmis";
    $teamdata{$k} = sprintf "%.2f", $avgTmis{$t};
    $high{'tmis'} = $teamdata{$k} if ($avgTmis{$t} == $highTmis);
    $k = "${t}tbnc";
    $teamdata{$k} = sprintf "%.2f", $avgTbnc{$t};
    $high{'tbnc'} = $teamdata{$k} if ($avgTbnc{$t} == $highTbnc);
    $k = "${t}trung";
    $teamdata{$k} = sprintf "%.2f", $avgTRung{$t};
    $high{'trung'} = $teamdata{$k} if ($avgTRung{$t} == $highTRung);
    $printdata{$k} = sprintf "%d/%d", $teamTRung{$t}, $teamCount{$t};
    $k = "${t}hrung";
    $teamdata{$k} = sprintf "%.2f", $avgHRung{$t};
    $high{'hrung'} = $teamdata{$k} if ($avgHRung{$t} == $highHRung);
    $printdata{$k} = sprintf "%d/%d", $teamHRung{$t}, $teamCount{$t};
    $k = "${t}mrung";
    $teamdata{$k} = sprintf "%.2f", $avgMRung{$t};
    $high{'mrung'} = $teamdata{$k} if ($avgMRung{$t} == $highMRung);
    $printdata{$k} = sprintf "%d/%d", $teamMRung{$t}, $teamCount{$t};
    $k = "${t}lrung";
    $teamdata{$k} = sprintf "%.2f", $avgLRung{$t};
    $high{'lrung'} = $teamdata{$k} if ($avgLRung{$t} == $highLRung);
    $printdata{$k} = sprintf "%d/%d", $teamLRung{$t}, $teamCount{$t};
}

#
# Print table
#

#
#  ############ NO Game-Specific Code Below Here ############ 
#

my $size = @teams;


# print the JS first
print "  <script>\n";
print "    const list = ";
my $pre = "[\n";
foreach my $t (@teams) {
    print "$pre";
    $pre = ",\n";
    print "      { 'team':$t,'bg':'a','opr':";
    my $k = "${t}opr";
    print "$teamdata{$k}";
    my $aline = "<TD";
    $aline .= " BGCOLOR=\"#0F0\"" if ($teamdata{$k} == $highOpr);
    $aline .= ">$teamdata{$k}</TD>";
    my $bline = "<TD BGCOLOR=\"#888\">$teamdata{$k}</TD>";
    foreach my $m (@metrics) {
	print ", '$m':";
	$k = "${t}$m";
	print "$teamdata{$k}";
	$aline .= "<TD";
	if ($high{$m} != 0.00 && $teamdata{$k} == $high{$m}) {
	    $aline .= " BGCOLOR=\"#0F0\"";
	} else {
	    # tint the printdata
	    $aline .= " BGCOLOR=\"#CCC\"" if (exists $printdata{$k});
	}
	# if the value is 0.00 then don't print it 
	if ("$teamdata{$k}" eq "0.00") {
	    $aline .= ">&nbsp;</TD>";
	    $bline .= "<TD BGCOLOR=\"#888\">&nbsp;</TD>";
	} else {
	    if (exists $printdata{$k}) {
		$aline .= ">$printdata{$k}</TD>";
		$bline .= "<TD BGCOLOR=\"#888\">$printdata{$k}</TD>";
	    } else {
		$aline .= ">$teamdata{$k}</TD>";
		$bline .= "<TD BGCOLOR=\"#888\">$teamdata{$k}</TD>";
	    }
	}
    }
    print ", 'aline':'$aline', 'bline':'$bline'";
    print ",'overlayt':'$teamOverlayT1{$t}</table><br>$teamOverlayT2{$t}</table><br>$teamOverlayT3{$t}</table>'";
    print "}";
}

print "\n    ]\n";
print "\n";
print "    function assign_table() {\n";
for (my $i = 0; $i < $size; $i++) {
    my $j = $i + 1;
    print "      if (list[$i].bg == 'a') {\n";
    print "        document.getElementById(\"row${j}\").innerHTML = list[$i].aline;\n";
    print "      } else {\n";
    print "        document.getElementById(\"row${j}\").innerHTML = list[$i].bline;\n";
    print "      }\n";
    print "        document.getElementById(\"det${j}\").innerHTML = '<td onclick=\"changeColor($i)\"><font color=\"blue\">' + list[$i].team + '</font></td>';\n";
}
print "    }\n";
print "\n";
print "    function sortteam() {\n";
print "      list.sort((a,b) => (a.team - b.team));\n";
print "      document.getElementById(\"mytitle\").innerHTML = \"Team-based pick list\";\n";
print "      assign_table();\n";
print "    }\n";
print "\n";
print "    function sortopr() {\n";
print "      list.sort((a,b) => (b.opr - a.opr));\n";
print "      document.getElementById(\"mytitle\").innerHTML = \"OPR-based pick list\";\n";
print "      assign_table();\n";
print "    }\n";
foreach my $m (@metrics) {
    print "    function sort${m}() {\n";
    print "      list.sort((a,b) => (b.$m > a.$m) ? 1 : (b.$m == a.$m) ? (b.opr - a.opr) : -1);\n";
    my $str = $humanStr{$m};
    $str =~ s/<BR>/ /g;
    print "      document.getElementById(\"mytitle\").innerHTML = \"Pick list sorted by $str\";\n";
    print "      assign_table();\n";
    print "    }\n";
}
print "    function changeColor(index) {\n";
print "      if (list[index].bg == \"a\") {\n";
print "        list[index].bg = \"b\";\n";
print "      } else {\n";
print "        list[index].bg = \"a\";\n";
print "      }\n";
print "      assign_table();\n";
print "    }\n";
print "    function on(index) {\n";
print "      document.getElementById(\"overlay\").style.display = \"block\";\n";
print "      document.getElementById(\"text\").innerHTML = list[index].overlayt;\n";
print "    }\n";
print "    function off() {\n";
print "      document.getElementById(\"overlay\").style.display = \"none\";\n";
print "    }\n";
print "    window.onload = function () {\n";
print "      sortopr();\n";
print "    }\n";
print "  </script>\n";
print "\n";

print "<div id=\"overlay\" onclick=\"off()\">\n";
print "  <div id=\"text\">Team Data</div>\n";
print "</div>\n";

print "<H1 id=\"mytitle\">OPR-based pick list</H1>\n";
#print "<p><a href=\"index.cgi\">Home</a></p>\n";

print "<h3>Do not use browser buttons without network connection</h3>\n";
print "<h3>Click/Tap on data to get detailed per-match information</h3>\n";
print "<h3>Click/Tap on team number to mark team as 'picked'</h3>\n";

print "<table cellpadding=0 cellspacing=0 border=0>\n";
print "<tr><td>\n";

print "<table cellpadding=5 cellspacing=3 border=1\n";
print " <tr>\n";
print "  <td><button onclick=\"sortteam()\">&nbsp;<br>Team<br>&nbsp;</button></td>\n";
print " </tr>\n";
for (my $i = 0; $i < $size; $i++) {
    my $j = $i + 1;
    print " <tr id=\"det$j\">\n";
    print "  <td><p>&nbsp;</p></td>";
    print " </tr>\n";
}
print "</table>\n";

print "</td><td>\n";

print "<table cellpadding=5 cellspacing=3 border=1>\n";
print " <tr>\n";
print "   <td><button onclick=\"sortopr()\">OPR</button></td>\n";
foreach my $m (@metrics) {
    print "   <td><button onclick=\"sort$m()\">$humanStr{$m}</button></td>\n";
}
print " </tr>\n";
for (my $i = 0; $i < $size; $i++) {
  my $j = $i + 1;
  print " <tr id=\"row$j\" onclick=\"on($i);\">\n";
  print "   <td><p>&nbsp;</p></td>\n";
  print "   <td><p>&nbsp;</p></td>\n";
  foreach my $m (@metrics) {
      print "   <td><p>&nbsp;</p></td>\n";
  }
  print " </tr>\n";
}
print "</table>\n";
print "</td></tr></table>\n";
print "<p>* Human Player points are not included in OPR score.</p>\n";
print "</body>\n";
print "</html>\n";
