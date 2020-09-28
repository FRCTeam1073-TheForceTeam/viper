#!/usr/bin/perl -w

use strict;
use warnings;

my $event = "";
my @picked;
my %pickhash;
my $me = "pick.cgi";
my $pics = "/scoutpics";

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
	if (defined $params{'picked'}) {
		@picked = split /,/, $params{'picked'};
		foreach my $p (@picked) {
			my $x = int $p;
			$pickhash{$x} = 1;
		}
	}
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"orange\"><center>\n";

if ($event eq "") {
    print "<H2>Error, need an event</H2>\n";
    print "</body></html>\n";
    exit 0;
}

my $file = "csv/${event}.csv";
if (! -f $file) {
    print "<H2>Error, file $file does not exist</H2>\n";
    print "</body></html>\n";
    exit 0;
}

my %teamCount;
my %cargohatch;
my %cargocargo;
my %rockethatch;
my %rocketcargo;
if ( open(my $fh, "<", $file) ) {
    while (my $line = <$fh>) {
		my @items = split /,/, $line;
		next if (@items < 23 || $items[0] eq "event");
		my $team  = int $items[2];
		$cargohatch{$team}  = 0 unless (defined $cargohatch{$team});
		$cargocargo{$team}  = 0 unless (defined $cargocargo{$team});
		$rockethatch{$team} = 0 unless (defined $rockethatch{$team});
		$rocketcargo{$team} = 0 unless (defined $rocketcargo{$team});
		# auto_hatch_cs = 7
		# auto_cargo_cs = 8
		# auto_hatch_r1 = 9
		# auto_hatch_r2 = 10
		# auto_hatch_r3 = 11
		# auto_cargo_r1 = 12
		# auto_cargo_r2 = 13
		# auto_cargo_r3 = 14
		# hatch_cs = 15
		# hatch_r1 = 16
		# hatch_r2 = 17
		# hatch_r3 = 18
		# cargo_cs = 19
		# cargo_r1 = 20
		# cargo_r2 = 21
		# cargo_r3 = 22
		my $cshatch = int $items[7];
		$cshatch += int $items[15];
		$cargohatch{$team} += $cshatch * 2;
		my $cscargo = int $items[8];
		$cscargo += int $items[19];
		$cargocargo{$team} += $cscargo * 3;
		my $rhatch = int $items[9] + int $items[10] + int $items[11];
		$rhatch += int $items[16] + int $items[17] + int $items[18];
		$rockethatch{$team} += $rhatch * 2;
		my $rcargo = int $items[12] + int $items[13] + int $items[14];
		$rcargo += int $items[20] + int $items[21] + int $items[22];
		$rocketcargo{$team} += $rcargo * 3;

		$teamCount{$team} = 0 unless (defined $teamCount{$team});
		$teamCount{$team} += 1;
    }
    close $fh;
} else {
    print "<H2>Error, could not open $file: $!</H2>\n";
    print "</body></html>\n";
    exit 0;
}

my @dchlist;
my @dcclist;
my @drhlist;
my @drclist;

my @teams = sort {$a <=> $b} keys %teamCount;

# average and add to list
foreach my $t (@teams) {
    my $score = $cargohatch{$t} / $teamCount{$t};
    my $str = sprintf "%.3f_%s", $score, $t;
    push @dchlist, $str;
	$score = $cargocargo{$t} / $teamCount{$t};
	$str = sprintf "%.3f_%s", $score, $t;
	push @dcclist, $str;
	$score = $rockethatch{$t} / $teamCount{$t};
	$str = sprintf "%.3f_%s", $score, $t;
	push @drhlist, $str;
	$score = $rocketcargo{$t} / $teamCount{$t};
	$str = sprintf "%.3f_%s", $score, $t;
	push @drclist, $str;
}

sub picksort {
    my @abits = split /_/, $a;
    my @bbits = split /_/, $b;
    my $anum = int $abits[0];
    my $bnum = int $bbits[0];
    return $bnum <=> $anum;
}

my @chlist = sort picksort @dchlist;
my @cclist = sort picksort @dcclist;
my @rhlist = sort picksort @drhlist;
my @rclist = sort picksort @drclist;

print "<H1>Scoring Results</H1>\n";
print "<table cellpadding=5 cellspacing=5 border=1><tr>\n";
print "<td>\n";
# print the team selector table
print "<table cellpadding=5 cellspacing=0 border=1>\n";
my $width = 100;
my $height = 100;
my $pickstr = "";
if (@picked > 0) {
	$pickstr = join ',', @picked;
}
foreach my $t (@teams) {
	if (exists $pickhash{$t}) {
		# create a pick string without this team
		my $str = "";
		foreach my $a (@picked) {
			next if ($a == $t);
			if ($str eq "") {
				$str = sprintf "%d", $a;
			} else {
				$str = sprintf "%s,%d", $str, $a;
			}
		}
		print "<tr><td><a href=\"${me}";
		print "?picked=$str" if ($str ne "");
		print "\"><img src=\"$pics/top_red_habx.png\"></a></td>\n";
	} else {
		# create a pick string with this team
		my $str = sprintf "%d", $t;
		
		foreach my $a (@picked) {
			$str = sprintf "%s,%d", $str, $a;
		}
		print "<tr><td><a href=\"${me}?picked=$str\">";
		print "<img src=\"$pics/top_red_hab.png\"></a></td>\n";
	}
	my $str = sprintf "%d", $t;
	print "<td>$str</td></tr>\n";
}
print "</table>\n";

print "</table></body></html>\n";
