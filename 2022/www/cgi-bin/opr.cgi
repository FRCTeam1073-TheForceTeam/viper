#!/usr/bin/perl

use strict;
use warnings;

my $green = "#7ef542";
my $event = "";

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
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<html lang=\"en\">\n";
print "<head>\n";
print "    <meta charset=\"utf-8\"/>\n";
print "    <title>FRC Scouting App</title>\n";
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
    $teamRung{$team} = 0 unless (defined $teamRung{$team});

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
    $teamRung{$team} += $rung;

    # assuming that the human scores in upper hub during auto
    # UPDATE: T and E say don't add HP points to OPR: "unfair to robot!"
    #my $score = ($taxi * 2) + ($human * 4) + ($Ahi * 2) + ($Ahi * 4);
    my $score = ($taxi * 2) + ($Ahi * 2) + ($Ahi * 4);
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
my %avgRung;

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
my $highRung = 0;

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
    $avgRung{$k}  = $teamRung{$k} / $teamCount{$k};

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
    $highRung  = $avgRung{$k} if ($avgRung{$k} > $highRung);
}

# assign JS data variables @teams, @metrics, and %teamdata
my @teams = keys %teamScore;
# opr is in the %teamdata but not listed in the metrics
# metric sort falls back on opr when metric values match
# metrics here are in the order in which they will be listed
my @metrics = ('taxi', 'human', 'alo', 'ahi', 'amis', 'abnc', 'tlo', 'thi', 'tmis', 'tbnc', 'rung');
my %humanStr = (taxi => 'Avg #<BR>Taxi<BR>Good', human => 'Avg #<BR>Human<BR>Score*',
		alo => 'Avg #<BR>Auto<BR>Lower', ahi => 'Avg #<BR>Auto<BR>Upper',
		amis => 'Avg #<BR>Auto<BR>Missed', abnc => 'Avg #<BR>Auto<BR>Bounced',
		tlo => 'Avg #<BR>Lower<BR>Cargo', thi => 'Avg #<BR>Upper<BR>Cargo',
		tmis => 'Avg #<BR>Missed<BR>Cargo', tbnc => 'Avg #<BR>Bounced<BR>Cargo',
		rung => 'Avg #<BR>Rungs<BR>Reached');
my %teamdata;
my %high;
foreach my $t (@teams) {
    my $k = "${t}opr";
    $teamdata{$k} = sprintf "%.2f", $avgOpr{$t};
    $highOpr = $teamdata{$k} if ($avgOpr{$t} == $highOpr);
    $k = "${t}taxi";
    $teamdata{$k} = sprintf "%.2f", $avgTaxi{$t};
    $high{'taxi'} = $teamdata{$k} if ($avgTaxi{$t} == $highTaxi);
    $k = "${t}human";
    $teamdata{$k} = sprintf "%.2f", $avgHuman{$t};
    $high{'human'} = $teamdata{$k} if ($avgHuman{$t} == $highHuman);
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
    $k = "${t}rung";
    $teamdata{$k} = sprintf "%.2f", $avgRung{$t};
    $high{'rung'} = $teamdata{$k} if ($avgRung{$t} == $highRung);
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
	$aline .= " BGCOLOR=\"#0F0\"" if ($teamdata{$k} == $high{$m});
	$aline .= ">$teamdata{$k}</TD>";
	$bline .= "<TD BGCOLOR=\"#888\">$teamdata{$k}</TD>";
    }
    print ", 'aline':'$aline', 'bline':'$bline'";
    print "}";
}

print "\n    ]\n";
print "\n";
print "    function assign_table() {\n";
for (my $i = 0; $i < $size; $i++) {
    my $j = $i + 1;
    print "      if (list[$i].bg == 'a') {\n";
    print "        document.getElementById(\"row${j}\").innerHTML = list[$i].aline;\n";
#    print "        document.getElementById(\"det${j}\").innerHTML = '<td><A href=\"team.cgi?event=$event&team=' + list[$i].team + '\">' + list[$i].team + '</A></td>';\n";
    print "      } else {\n";
    print "        document.getElementById(\"row${j}\").innerHTML = list[$i].bline;\n";
#    print "        document.getElementById(\"det${j}\").innerHTML = '<td bgcolor=\"#AAA\">' + list[$i].team + '</td>';\n";
    print "      }\n";
    print "        document.getElementById(\"det${j}\").innerHTML = '<td><A href=\"team.cgi?event=$event&team=' + list[$i].team + '\">' + list[$i].team + '</A></td>';\n";
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
print "    function changeColor(thisRow, index) {\n";
print "      if (list[index].bg == \"a\") {\n";
print "        list[index].bg = \"b\";\n";
print "      } else {\n";
print "        list[index].bg = \"a\";\n";
print "      }\n";
print "      assign_table();\n";
print "    }\n";
print "    window.onload = function () {\n";
print "      sortopr();\n";
print "    }\n";
print "  </script>\n";
print "\n";

print "<H1 id=\"mytitle\">OPR-based pick list</H1>\n";
#print "<p><a href=\"index.cgi\">Home</a></p>\n";

print "<h3>Do not use browser buttons without network connection</h3>\n";
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
  print " <tr id=\"row$j\" onclick=\"changeColor(this, $i);\">\n";
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
