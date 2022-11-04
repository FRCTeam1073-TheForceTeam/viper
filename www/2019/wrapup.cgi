#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $game = $cgi->param('game')||'';
$webutil->error("Bad game parameter", $game) if ($game !~ /^2019[0-9a-zA-Z\-]+_(qm|qf|sm|f)[0-9]+_[RB][1-3]$/);
my $team = $cgi->param('team')||"";
$webutil->error("Bad team parameter", $team) if ($team !~ /^[0-9]+$/);
my $cargo = $cgi->param('cargo')||"0000000000000000";
$webutil->error("Bad cargo parameter", $cargo) if ($cargo !~ /^[0-2]{16}$/);
my $rocket = $cgi->param('rocket')||"000000000000000000000000";
$webutil->error("Bad rocket parameter", $rocket) if ($rocket !~ /^[0-2]{24}$/);
my $hab = $cgi->param('hab')||"00";

# print web page beginning
print "Content-type: text/html; charset=UTF-8\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body><center>\n";

# declare the form
print "<form action=\"score.cgi\" id=\"wrapup\" enctype=\"text/plain\">\n";
print "<input type=\"hidden\" name=\"game\" value=\"$game\">\n";
print "<input type=\"hidden\" name=\"team\" value=\"$team\">\n";
print "<input type=\"hidden\" name=\"cargo\" value=\"$cargo\">\n";
print "<input type=\"hidden\" name=\"rocket\" value=\"$rocket\">\n";
print "<input type=\"hidden\" name=\"hab\" value=\"$hab\">\n";

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

print "<h2>Scouter Name: <input type=\"text\" name=\"scouter\"></h2>\n";

print "<h2>Comments: <textarea name=\"comments\" form=\"wrapup\" cols=\"50\" rows=\"5\"></textarea></h2>\n";

print "<input type=\"submit\" value=\"Save answers\">";

print "</body></html>\n";
