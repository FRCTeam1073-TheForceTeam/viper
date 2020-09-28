#!/usr/bin/perl -w

use strict;
use warnings;

my $game = '2019UNH_qm1_1';
my $team = "1234";
my $cargo = "0000000000000000";
my $rocket = "000000000000000000000000";
my $hab = "00";

#
# read in previous game state
#
if ($ENV{QUERY_STRING}) {
	my @args = split /\&/, $ENV{QUERY_STRING};
	my %params;
	foreach my $arg (@args) {
		my @bits = split /=/, $arg;
		next unless (@bits == 2);
		$params{$bits[0]} = $bits[1];
	}
	$game   = $params{'game'}   if (defined $params{'game'});
	$team   = $params{'team'}   if (defined $params{'team'});
    $cargo  = $params{'cargo'}  if (defined $params{'cargo'});
	$rocket = $params{'rocket'} if (defined $params{'rocket'});
	$hab    = $params{'hab'}    if (defined $params{'hab'});
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body><center>\n";

# declare the form
print "<FORM ACTION=\"score.cgi\" id=\"wrapup\" enctype=\"text/plain\">\n";
print "<INPUT type=\"hidden\" name=\"game\" value=\"$game\">\n";
print "<INPUT type=\"hidden\" name=\"team\" value=\"$team\">\n";
print "<INPUT type=\"hidden\" name=\"cargo\" value=\"$cargo\">\n";
print "<INPUT type=\"hidden\" name=\"rocket\" value=\"$rocket\">\n";
print "<INPUT type=\"hidden\" name=\"hab\" value=\"$hab\">\n";

print "<h1>Match summary questions</h1>\n";

print "<table border=0 cellpadding=5 cellspacing=0>\n";
print "<tr><th colspan=3><h2>Did $team play defense?</h2></th><tr>\n";
print "<tr><td><input type=\"radio\" name=\"defense\" value=\"3\"></td>\n";
print "<td><h3>Good defense</h3></td>\n";
print "<td><p>not many game pieces scored by opponent during defense</p></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"defense\" value=\"2\"></td>\n";
print "<td><h3>Average defense</h3></td>\n";
print "<td><p>opponent was still able to score some game pieces</p></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"defense\" value=\"1\"></td>\n";
print "<td><h3>Below average defense</h3></td>\n";
print "<td><p>opponent was still able to score game pieces</p></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"defense\" value=\"0\" CHECKED></td>\n";
print "<td><h3>No defense played</h3></td><td>&nbsp;</td></tr>\n";
print "</table><hr>\n";

print "<table border=0 cellpadding=5 cellspacing=0>\n";
print "<tr><th colspan=3><h2>Was $team defended?</h2></th><tr>\n";
print "<tr><td><input type=\"radio\" name=\"defended\" value=\"3\"></td>\n";
print "<td><h3>Good against defense</h3></td>\n";
print "<td><p>defended but still scored game pieces</p></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"defended\" value=\"2\"></td>\n";
print "<td><h3>Average against defense</h3></td>\n";
print "<td><p>defended but still able to score some game pieces</p></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"defended\" value=\"1\"></td>\n";
print "<td><h3>Affected by defense</h3></td>\n";
print "<td><p>good defense really affected robot performance</p></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"defended\" value=\"0\" CHECKED></td>\n";
print "<td><h3>Not defended</h3></td><td>&nbsp;</td></tr>\n";
print "</table><hr>\n";

print "<table border=0 cellpadding=5 cellspacing=0>\n";
print "<tr><th><h2>Did $team receive any fouls?</h2></th>";
print "<th><h2>Did $team receive any tech fouls?</h2></th><tr>\n";
print "<tr><td><input type=\"radio\" name=\"fouls\" value=\"3\"><b>Many fouls</b></td>\n";
print "<td><input type=\"radio\" name=\"techfouls\" value=\"3\"><b>Many tech fouls</b></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"fouls\" value=\"2\"><b>A few fouls</b></td>\n";
print "<td><input type=\"radio\" name=\"techfouls\" value=\"2\"><b>A few tech fouls</b></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"fouls\" value=\"1\"><b>One foul</b></td>\n";
print "<td><input type=\"radio\" name=\"techfouls\" value=\"1\"><b>One tech foul</b></td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"fouls\" value=\"0\" CHECKED><b>No fouls</b></td>\n";
print "<td><input type=\"radio\" name=\"techfouls\" value=\"0\" CHECKED><b>No tech fouls</b></td></tr>\n";
print "</table><hr>\n";

print "<table border=0 cellpadding=5 cellspacing=0>\n";
print "<tr><th><h2>Is $team a good robot?</h2></th><tr>\n";
print "<tr><td><input type=\"radio\" name=\"rank\" value=\"3\"><b>Very good robot</b>: could be an alliance captain</td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"rank\" value=\"2\"><b>Decent robot</b>: a productive robot</td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"rank\" value=\"1\"><b>Struggled to be effective</b>: maybe good at one thing, but bad at others</td></tr>\n";
print "<tr><td><input type=\"radio\" name=\"rank\" value=\"0\" CHECKED><b>Unknown</b>: robot was disabled, did not participate, etc.</td></tr>\n";
print "</table><hr>\n";

print "<H2>Scouter Name: <input type=\"text\" name=\"scouter\"></H2>\n";

print "<H2>Comments: <textarea name=\"comments\" form=\"wrapup\" cols=\"50\" rows=\"5\"></textarea></H2>\n";

print "<input type=\"submit\" value=\"Save answers\">";

print "</body></html>\n";
