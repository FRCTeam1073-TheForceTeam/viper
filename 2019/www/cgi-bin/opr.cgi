#!/usr/bin/perl -w

use strict;
use warnings;

my $me = "opr.cgi";
my $pics = "/scoutpics";
my $width = 60;
my $height = 60;

my $event = "";
# keep picked list in selected order with array
my @picked;
# use hash for quick 'existence' test
my %pickhash;
# use 'clear' option to pass selected team to remove rather than
# rebuild pick list for every link
my $clear = "";
# 'sort by' setting
# can be 'opr', 'hatch', 'cargo', 'lvl3'
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
    print "<H2>Error, could not open $file: $!</H2>\n";
    print "</body></html>\n";
    exit 0;
}


# sort function
sub picksort {
    my @abits = split /_/, $a;
    my @bbits = split /_/, $b;
    return $bbits[0] <=> $abits[0];
}

#
# sort teams by OPR
#
my @dlist;

# average and add to list
foreach my $k (keys %teamScore) {
    my $score = "";
	$score = $teamScore{$k} / $teamCount{$k} if ("$order" eq "opr");
	$score = $teamHatch{$k} / $teamCount{$k} if ("$order" eq "hatch");
	$score = $teamCargo{$k} / $teamCount{$k} if ("$order" eq "cargo");
	$score = $teamEnd3{$k} / $teamCount{$k} if ("$order" eq "lvl3");
	
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
print "<TH><a href=\"${me}?event=$event";
print "&picked=$pstr" if ($pstr ne "");
print "\">OPR</a></TH>";
#Hatches
print "<TH><a href=\"${me}?event=$event";
print "&picked=$pstr" if ($pstr ne "");
print "&order=hatch\">Avg. #Hatches</a></TH>";
#Cargo
print "<TH><a href=\"${me}?event=$event";
print "&picked=$pstr" if ($pstr ne "");
print "&order=cargo\">Avg. #Cargo</a></TH>";
# LVL3
print "<TH><a href=\"${me}?event=$event";
print "&picked=$pstr" if ($pstr ne "");
print "&order=lvl3\">Avg. Lvl 3</a></TH>";
#print "<TH>Avg. #Hatches</TH>";
#print "<TH>Avg. #Cargo</TH>";
#print "<TH>Avg Lvl 3</TH>";
print "<TH>Avg Lvl 2</TH><TH>Avg Lvl 1</TH>\n";

foreach my $t (@plist) {
    my @items = split /_/, $t;
    next unless (@items > 1);
	
	my $opr   = $teamScore{$items[1]} / $teamCount{$items[1]};
	my $hatch = $teamHatch{$items[1]} / $teamCount{$items[1]};
	my $cargo = $teamCargo{$items[1]} / $teamCount{$items[1]};
	my $end1  = $teamEnd1{$items[1]} / $teamCount{$items[1]};
	my $end2  = $teamEnd2{$items[1]} / $teamCount{$items[1]};
	my $end3  = $teamEnd3{$items[1]} / $teamCount{$items[1]};
	print "<tr><td><a href=\"${me}?event=$event";
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
	my $ostr = sprintf "%.3f", $opr;
	$bgcolor = "BGCOLOR=\"GRAY\"" if (exists $pickhash{$items[1]});
	print "<td $bgcolor><h2><a href=\"team.cgi?team=$items[1]&event=$event\">$items[1]</a></h2></td>";
	print "<td $bgcolor><h2>$ostr</h2></td>";
	my $hstr = sprintf "%.3f", $hatch;
	my $cstr = sprintf "%.3f", $cargo;
	my $e1st = sprintf "%.3f", $end1;
	my $e2st = sprintf "%.3f", $end2;
	my $e3st = sprintf "%.3f", $end3;
	
	print "<td $bgcolor><h3>$hstr</h3></td>";
	print "<td $bgcolor><h3>$cstr</h3></td>";
	print "<td $bgcolor><h3>$e3st</h3></td>";
	print "<td $bgcolor><h3>$e2st</h3></td>";
	print "<td $bgcolor><h3>$e1st</h3></td></tr>\n";
}
print "</table></body></html>\n";
