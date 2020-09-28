#!/usr/bin/perl -w

use strict;
use warnings;

my $me = "opr.cgi";
my $pics = "/scoutpics";
my $width = 60;
my $height = 60;
my $green = "#7ef542";

my $event = "";
# keep picked list in selected order with array
my @picked;
# use hash for quick 'existence' test
my %pickhash;
# use 'clear' option to pass selected team to remove rather than
# rebuild pick list for every link
my $clear = "";
# 'sort by' setting
# can be 'opr', 'power', 'rotate', 'ctrl'
my $order = "opr";

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
    $clear = $params{'clear'}  if (defined $params{'clear'});
    $order = $params{'order'}  if (defined $params{'order'});
    if (defined $params{'picked'}) {
	my @plist = split /,/, $params{'picked'};
	foreach my $p (@plist) {
	    next if ($clear eq $p);
	    push @picked, $p;
	    $pickhash{$p} = 1;
	}
    }
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

my %teamALine;
my %teamABPort;
my %teamAOPort;
my %teamAIPort;
my %teamTBPort;
my %teamTOPort;
my %teamTIPort;
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
	my $team  = $items[2];
	my $ALine = $items[3];
	my $ABot  = $items[4];
	my $AOut  = $items[5];
	my $AInn  = $items[6];
	my $TBot  = $items[7];
	my $TOut  = $items[8];
	my $TInn  = $items[9];
	my $amiss  = $items[10];
	my $tmiss  = $items[11];
	my $rotate = $items[37];
	my $position = $items[38];
	my $park  = $items[39];
	my $climb = $items[40];
	my $level = $items[43];
	
	# missing initiation line and end game scoring
	$teamScore{$team}  = 0 unless (defined $teamScore{$team});
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
	$teamALine{$team}  += $ALine;
	$teamABPort{$team} += $ABot;
	$teamAOPort{$team} += $AOut;
	$teamAIPort{$team} += $AInn;
	$teamTBPort{$team} += $TBot;
	$teamTOPort{$team} += $TOut;
	$teamTIPort{$team} += $TInn;
	$teamAMissd{$team} += $amiss;
	$teamTMissd{$team} += $tmiss;
	$teamRotate{$team} += $rotate;
	$teamPosition{$team} += $position;
	$teamPark{$team}   += $park;
	$teamClimb{$team}  += $climb;
	$teamLevel{$team}  += $level;

	my $score = ($ALine * 5) + ($ABot * 2) + ($AOut * 4);
	$score += ($AInn * 6) + $TBot + ($TOut * 2) + ($TInn * 3);
	$score += 10 if ($rotate != 0);
	$score += 20 if ($position != 0);
	$score += 5  if ($park != 0);
	$score += 25 if ($climb != 0);
	$score += 15 if ($level != 0);
	$teamScore{$team} += $score;
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


# sort function
sub picksort {
    my @abits = split /_/, $a;
    my @bbits = split /_/, $b;
    if ("$bbits[0]" eq "$abits[0]") {
	return $bbits[1] <=> $abits[1];
    }
    return $bbits[0] <=> $abits[0];
}

#
# sort teams by selected column and compute high scores for each column
#
my @dlist;

my %avgOpr;
my %avgAline;
my %avgABPort;
my %avgAOPort;
my %avgAIPort;
my %avgTBPort;
my %avgTOPort;
my %avgTIPort;
my %avgAMissd;
my %avgTMissd;
my %avgRotate;
my %avgPosition;
my %avgPark;
my %avgClimb;
my %avgLevel;

my $highOpr = 0;
my $highAline = 0;
my $highAbot = 0;
my $highAout = 0;
my $highAinn = 0;
my $highTbot = 0;
my $highTout = 0;
my $highTinn = 0;
my $highAMis = 0;
my $highTMis = 0;
my $highRota = 0;
my $highPosi = 0;
my $highPark = 0;
my $highClim = 0;
my $highLevl = 0;

# average and add to list
foreach my $k (keys %teamScore) {

    $avgOpr{$k}    = $teamScore{$k} / $teamCount{$k};
    $avgAline{$k}  = $teamALine{$k} / $teamCount{$k};
    $avgABPort{$k} = $teamABPort{$k} / $teamCount{$k};
    $avgAOPort{$k} = $teamAOPort{$k} / $teamCount{$k};
    $avgAIPort{$k} = $teamAIPort{$k} / $teamCount{$k};
    $avgTBPort{$k} = $teamTBPort{$k} / $teamCount{$k};
    $avgTOPort{$k} = $teamTOPort{$k} / $teamCount{$k};
    $avgTIPort{$k} = $teamTIPort{$k} / $teamCount{$k};
    $avgAMissd{$k} = $teamAMissd{$k} / $teamCount{$k};
    $avgTMissd{$k} = $teamTMissd{$k} / $teamCount{$k};
    $avgRotate{$k} = $teamRotate{$k} / $teamCount{$k};
    $avgPosition{$k} = $teamPosition{$k} / $teamCount{$k};
    $avgPark{$k}   = $teamPark{$k} / $teamCount{$k};
    $avgClimb{$k}  = $teamClimb{$k} / $teamCount{$k};
    $avgLevel{$k}  = $teamLevel{$k} / $teamCount{$k};

    $highOpr  = $avgOpr{$k} if ($avgOpr{$k} > $highOpr);
    $highAline = $avgAline{$k} if ($avgAline{$k} > $highAline);
    $highAbot = $avgABPort{$k} if ($avgABPort{$k} > $highAbot);
    $highAout = $avgAOPort{$k} if ($avgAOPort{$k} > $highAout);
    $highAinn = $avgAIPort{$k} if ($avgAIPort{$k} > $highAinn);
    $highTbot = $avgTBPort{$k} if ($avgTBPort{$k} > $highTbot);
    $highTout = $avgTOPort{$k} if ($avgTOPort{$k} > $highTout);
    $highTinn = $avgTIPort{$k} if ($avgTIPort{$k} > $highTinn);
    $highAMis = $avgAMissd{$k} if ($avgAMissd{$k} > $highAMis);
    $highTMis = $avgTMissd{$k} if ($avgTMissd{$k} > $highTMis);
    $highRota = $avgRotate{$k} if ($avgRotate{$k} > $highRota);
    $highPosi = $avgPosition{$k} if ($avgPosition{$k} > $highPosi);
    $highPark = $avgPark{$k}  if ($avgPark{$k} > $highPark);
    $highClim = $avgClimb{$k} if ($avgClimb{$k} > $highClim);
    $highLevl = $avgLevel{$k} if ($avgLevel{$k} > $highLevl);
    
    my $score = 0.0;
    $score = $avgOpr{$k}    if ("$order" eq "opr");
    $score = $avgAline{$k}  if ("$order" eq "autoline");
    $score = $avgABPort{$k} if ("$order" eq "autobot");
    $score = $avgAOPort{$k} if ("$order" eq "autoout");
    $score = $avgAIPort{$k} if ("$order" eq "autoin");
    $score = $avgTBPort{$k} if ("$order" eq "telebot");
    $score = $avgTOPort{$k} if ("$order" eq "teleout");
    $score = $avgTIPort{$k} if ("$order" eq "telein");
    $score = $avgAMissd{$k} if ("$order" eq "amissed");
    $score = $avgTMissd{$k} if ("$order" eq "tmissed");
    $score = $avgRotate{$k} if ("$order" eq "rotate");
    $score = $avgPosition{$k} if ("$order" eq "position");
    $score = $avgPark{$k}   if ("$order" eq "park");
    $score = $avgClimb{$k}  if ("$order" eq "climb");
    $score = $avgLevel{$k}  if ("$order" eq "level");
	
    my $str = sprintf "%.3f_%s", $score, $k;
    push @dlist, $str;
}
my @plist = sort picksort @dlist;

#
# Print table
#
my $pstr = "";
$pstr = join ',', @picked if (@picked > 0);

print "<H1>OPR-based pick list</H1>\n";
print "<p><a href=\"index.cgi\">Home</a></p>\n";
print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<th>Picked</th><th>Team</TH>";
#OPR
if ($order eq "opr") {
    print "<TH>OPR</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "\">OPR</a></TH>\n";
}
#ALine
if ($order eq "autoline") {
    print "<TH>Avg. #<br>Auto<br>Line</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=autoline\">Avg. #<br>Auto<br>Line</a></TH>\n";
}
#ABPort
if ($order eq "autobot") {
    print "<TH>Avg. #<br>Auto<br>Bottom</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=autobot\">Avg. #<br>Auto<br>Bottom</a></TH>\n";
}
#AOPort
if ($order eq "autoout") {
    print "<TH>Avg. #<br>Auto<br>Outer</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=autoout\">Avg. #<br>Auto<br>Outer</a></TH>\n";
}
#AIPort
if ($order eq "autoin") {
    print "<TH>Avg. #<br>Auto<br>Inner</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=autoin\">Avg. #<br>Auto<br>Inner</a></TH>\n";
}
# Telebot
if ($order eq "telebot") {
    print "<TH>Avg. #<br>TeleOp<br>Bottom</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=telebot\">Avg. #<br>TeleOp<br>Bottom</a></TH>\n";
}
# TeleOut
if ($order eq "teleout") {
    print "<TH>Avg. #<br>TeleOp<br>Outer</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=teleout\">Avg. #<br>TeleOp<br>Outer</a></TH>\n";
}
# TeleIn
if ($order eq "telein") {
    print "<TH>Avg. #<br>TeleOp<br>Inner</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=telein\">Avg. #<br>TeleOp<br>Inner</a></TH>\n";
}
# AMissed
if ($order eq "amissed") {
    print "<TH>Avg. #<br>Auto<br>Missed</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=amissed\">Avg. #<br>Auto<br>Missed</a></TH>\n";
}
# TMissed
if ($order eq "tmissed") {
    print "<TH>Avg. #<br>TeleOp<br>Missed</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=tmissed\">Avg. #<br>TeleOp<br>Missed</a></TH>\n";
}
# Rotation Control
if ($order eq "rotate") {
    print "<TH>Avg. #<br>Rotation<br>Control</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=rotate\">Avg. #<br>Rotation<br>Control</a></TH>\n";
}
# Position Control
if ($order eq "position") {
    print "<TH>Avg. #<br>Position<br>Control</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=position\">Avg. #<br>Position<br>Control</a></TH>\n";
}
# Climb
if ($order eq "park") {
    print "<TH>Avg. #<br>Parks</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=park\">Avg. #<br>Parks</a></TH>\n";
}
# Climb
if ($order eq "climb") {
    print "<TH>Avg. #<br>Climbs</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=climb\">Avg. #<br>Climbs</a></TH>\n";
}
# Level
if ($order eq "level") {
    print "<TH>Avg. #<br>Leveled</TH>\n";
} else {
    print "<TH><a href=\"${me}?event=$event";
    print "&picked=$pstr" if ($pstr ne "");
    print "&order=level\">Avg. #<br>Leveled</a></TH>\n";
}
print "</tr>\n";

foreach my $t (@plist) {
    my @items = split /_/, $t;
    next unless (@items > 1);
    
    print "<tr><td><a href=\"${me}?event=$event";
    print "&order=$order" if ($order ne "");
    print "&picked=$pstr" if ($pstr ne "");
    if (exists $pickhash{$items[1]}) {
	# team has been picked, so display 'X' with link to "unpick"
	print "&clear=$items[1]";
	print "\"><img height=$height width=$width src=\"$pics/top_red_habx.png\">";
    } else {
	# add this team to pick list
	if ($pstr ne "") {
	    print ",";
	} else {
	    print "&picked=";
	}
	print "$items[1]";
	print "\"><img height=$height width=$width src=\"$pics/top_red_hab.png\">";
    }
    print "</a></td>\n";
    my $bgcolor = "";
    my $ostr = sprintf "%.3f", $avgOpr{$items[1]};
    my $alstr = sprintf "%.3f", $avgAline{$items[1]};
    my $abstr = sprintf "%.3f", $avgABPort{$items[1]};
    my $aostr = sprintf "%.3f", $avgAOPort{$items[1]};
    my $aistr = sprintf "%.3f", $avgAIPort{$items[1]};
    my $tbstr = sprintf "%.3f", $avgTBPort{$items[1]};
    my $tostr = sprintf "%.3f", $avgTOPort{$items[1]};
    my $tistr = sprintf "%.3f", $avgTIPort{$items[1]};
    my $mastr = sprintf "%.3f", $avgAMissd{$items[1]};
    my $mtstr = sprintf "%.3f", $avgTMissd{$items[1]};
    my $rotstr = sprintf "%.3f", $avgRotate{$items[1]};
    my $posstr = sprintf "%.3f", $avgPosition{$items[1]};
    my $pkstr = sprintf "%.3f", $avgPark{$items[1]};
    my $clstr = sprintf "%.3f", $avgClimb{$items[1]};
    my $lvstr = sprintf "%.3f", $avgLevel{$items[1]};

    $bgcolor = "BGCOLOR=\"GRAY\"" if (exists $pickhash{$items[1]});
    print "<td $bgcolor><h2><a href=\"team.cgi?team=$items[1]&event=$event\">$items[1]</a></h2></td>";

    my $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgOpr{$items[1]} == $highOpr && ! exists $pickhash{$items[1]});
    print "<td $bgc><h2>$ostr</h2></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgAline{$items[1]} == $highAline && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$alstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgABPort{$items[1]} == $highAbot && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$abstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgAOPort{$items[1]} == $highAout && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$aostr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgAIPort{$items[1]} == $highAinn && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$aistr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgTBPort{$items[1]} == $highTbot && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$tbstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgTOPort{$items[1]} == $highTout && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$tostr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgTIPort{$items[1]} == $highTinn && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$tistr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgAMissd{$items[1]} == $highAMis && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$mastr</h3></td>";
    $bgc = $bgcolor;                                                                                                       $bgc = "bgcolor=\"$green\"" if ($avgTMissd{$items[1]} == $highTMis && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$mtstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgRotate{$items[1]} == $highRota && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$rotstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgPosition{$items[1]} == $highPosi && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$posstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgPark{$items[1]} == $highPark && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$pkstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgClimb{$items[1]} == $highClim && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$clstr</h3></td>";
    $bgc = $bgcolor;
    $bgc = "bgcolor=\"$green\"" if ($avgLevel{$items[1]} == $highLevl && ! exists $pickhash{$items[1]});
    print "<td $bgc><h3>$lvstr</h3></td>";
    print "</tr>\n";
}
print "</table></body></html>\n";
