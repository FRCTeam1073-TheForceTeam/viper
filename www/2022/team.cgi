#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use csv;
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $event = $cgi->param('event');
$webutil->error("No event parameter") if (!$event);
$webutil->error("Bad event parameter", $event) if ($event !~ /^20[0-9]{2}[0-9a-zA-Z_\-]+$/);
my $team = $cgi->param('team');
$webutil->error("No team parameter") if (!$team);
$webutil->error("Bad team parameter", $team) if ($team !~ /^[0-9]+$/);
my $file = "../data/${event}.txt";
$webutil->error("File does not exist", $file) if (! -f $file);

# print web page beginning
print "Content-type: text/html; charset=UTF-8\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";

my %game;
my %review;
my %scout;
my @match;
my $data = `cat $file`;
my $csv = new csv($data);
for my $row (1..$csv->getRowCount()){
    next if ($csv->getItemCount($row) < $csv->getHeaderCount());
    next unless ($team eq $csv->getByName($row,'team'));
    my $m = $csv->getByName($row,'match');
    # guard against duplicate match entries
    if (defined $game{$m}){
        my $suffix = "a";
        while (1) {
            my $index = $m . $suffix;
            if (defined $game{$index}) {
                ++$suffix;
                next;
            } else {
                $m = $index;
                last;
            }
        }
    }
    push @match, $m;

    $game{$m}  = "<td align=center><h2>".$csv->getByName($row,'taxi')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'human')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'auto_low_hub')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'auto_high_hub')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'teleop_low_hub')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'teleop_high_hub')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'auto_missed')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'teleop_missed')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'auto_bounce_out')."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$csv->getByName($row,'teleop_bounce_out')."</h2></td>";
    my $noYes = ["No","Yes"];
    $game{$m} .= "<td align=center><h2>".$noYes->[$csv->getByName($row,'shoot_from_hub') || 0]."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$noYes->[$csv->getByName($row,'shoot_from_field') || 0]."</h2></td>";
    $game{$m} .= "<td align=center><h2>".$noYes->[$csv->getByName($row,'shoot_from_outer_LP') || 0]."</h2></td>";
    $game{$m}  .= "<td align=center><h2>".$noYes->[$csv->getByName($row,'shoot_from_wallLP') || 0]."</h2></td>";
    my $rungs = ["None","Low","Middle","High","Traversal"];
    $game{$m} .= "<td align=center><h2>".$rungs->[$csv->getByName($row,'rung') || 0]."</h2></td>";
    my $fourGrades = ["None","Poor","Average","Good"];
    $review{$m}  = "<td align=center><h2>".$fourGrades->[$csv->getByName($row,'defense') || 0]."</h2></td>";
    $review{$m} .= "<td align=center><h2>".$fourGrades->[$csv->getByName($row,'defended') || 0]."</h2></td>";
    my $noneToThreePlus = ["None","One","Two","Three+"];
    $review{$m} .= "<td align=center><h2>".$noneToThreePlus->[$csv->getByName($row,'fouls') || 0]."</h2></td>";
    $review{$m} .= "<td align=center><h2>".$noneToThreePlus->[$csv->getByName($row,'techfouls') || 0]."</h2></td>";
    my $ranks = ["Unknown","Struggled","Decent","Very Good"];
    $review{$m} .= "<td align=center><h2>".$ranks->[$csv->getByName($row,'rank') || 0]."</h2></td>";
    $scout{$m} = "<td align=center><h2>".($csv->getByName($row,'scouter')||"&nbsp;")."</h2></td>";
    $scout{$m} .= "<td align=center><h2>".($csv->getByName($row,'comments')||"&nbsp;")."</h2></td>";
}

print "<h1>$team</h1>\n";
print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=16 align=center><h2>Game: Auto, TeleOp, and EndGame</h2></td></tr>\n";
print "<tr><th>Match</th><th>Taxi</th><th>Human</th>\n";
print "<th>Auto<br>Lower</th><th>Auto<br>Upper</th><th>TeleOp<br>Lower</th><th>TeleOp<br>Upper</th>\n";
print "<th>Auto<br>Missed</th><th>TeleOp<br>Missed</th><th>Auto<br>Bounced</th><th>TeleOp<br>Bounced</th>\n";
print "<th>Shoot<br>Hub</th><th>Shoot<br>Field</th><th>Shoot<br>Outer LP</th><th>Shoot<br>Wall LP</th>\n";
print "<th>EndGame<br>Rung</th>\n";
print "</tr><tr>\n";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$game{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=6 align=center><h2>Game Review</h2></td></tr>\n";
print "<tr><th>Match</th><th>Played<br>Defense</th><th>Against<br>Defense</th>";
print "<th>Fouls</th><th>Tech<br>Fouls</th><th>Rank</th></tr>\n";

foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$review{$m}</tr>\n";
}
print "</table>\n";

print "<table cellpadding=5 cellspacing=5 border=1>\n";
print "<tr><td colspan=3 align=center><h2>Scouter and Comments</h2></td></tr>\n";
print "<tr><th>Match</th><th>Name</th><th>Comments</th></tr>";
foreach my $m (@match) {
    print "<tr><td><h2>$m</h2></td>$scout{$m}</tr>\n";
}
print "</table>\n";

print "</body></html>\n";
