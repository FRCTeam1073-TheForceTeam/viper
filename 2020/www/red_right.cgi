#!/usr/bin/perl -w

use strict;
use warnings;

my $me = "red_right.cgi";
my $picdir = "/scoutpics";

my $game = '2019UNH_qm1_1';
my $team = '1234';
my $auto = "0-0-0-0";
my $teleop = "0-0-0";
my $missed = "0-0";
my $shotloc = "000000000000000000000000000000";
my $ctrl = "00";

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
    $game     = $params{'game'}    if (defined $params{'game'});
    $team     = $params{'team'}    if (defined $params{'team'});
    $auto     = $params{'auto'}    if (defined $params{'auto'});
    $teleop   = $params{'teleop'}  if (defined $params{'teleop'});
    $missed   = $params{'missed'}  if (defined $params{'missed'});
    $shotloc  = $params{'shotloc'} if (defined $params{'shotloc'});
    $ctrl     = $params{'ctrl'}    if (defined $params{'ctrl'});
}

my @gdata  = split '_', $game;
my $event  = $gdata[0];
my $match  = $gdata[1];
my $robot  = $gdata[2];
my @marray = split "-", $missed;
my @sarray = split "", $shotloc;
my @carray = split "", $ctrl;
my @aarray = split "-", $auto;
my @tarray = split "-", $teleop;


sub getposparams {
    my ($num, $count) = (@_);
    my $a = $aarray[0];
    my $b = $aarray[1];
    my $c = $aarray[2];
    my $x = $tarray[0];
    my $y = $tarray[1];
    my $z = $tarray[2];
    $a += $count if ($num == 1);
    $b += $count if ($num == 3);
    $c += $count if ($num == 5);
    $x += $count if ($num == 2);
    $y += $count if ($num == 4);
    $z += $count if ($num == 6);

    my $astr = "${a}-${b}-${c}-$aarray[3]";
    my $tstr = "${x}-${y}-${z}";
    return "auto=${astr}&teleop=${tstr}";
}

sub getnegparams {
    my ($num) = (@_);
    my $a = $aarray[0];
    my $b = $aarray[1];
    my $c = $aarray[2];
    my $x = $tarray[0];
    my $y = $tarray[1];
    my $z = $tarray[2];
    $a -= 1 if ($num == 1 && $a > 0);
    $b -= 1 if ($num == 3 && $b > 0);
    $c -= 1 if ($num == 5 && $c > 0);
    $x -= 1 if ($num == 2 && $x > 0);
    $y -= 1 if ($num == 4 && $y > 0);
    $z -= 1 if ($num == 6 && $z > 0);

    my $astr = "${a}-${b}-${c}-$aarray[3]";
    my $tstr = "${x}-${y}-${z}";
    return "auto=${astr}&teleop=${tstr}";
}

sub printCounter {
    my ($num) = (@_);

    print "<table cellpadding=5 cellspacing=0 border=0><tr>\n";
    print "<th colspan=2><p style=\"font-size:25px;\">";
    print "Inner Port" if ($num == 1 || $num == 2);
    print "Outer Port" if ($num == 3 || $num == 4);
    print "Bottom Port" if ($num == 5 || $num == 6);
	print " Counter" if ($num == 2 || $num == 4);
    print "</p></th></tr>\n";
    my $params = getposparams($num, 1);
    my $append = "game=${game}&team=${team}&${params}&shotloc=${shotloc}&ctrl=${ctrl}&missed=${missed}";
    print "<tr><td align=center><A href=\"${me}?${append}\"><img src=$picdir/count_up2.png></a></td>\n";

    print "<td bgcolor=white align=center>";
    if ($num == 2 || $num == 4 || $num == 6) {
	$params = getposparams($num, 5);
	$append = "game=${game}&team=${team}&${params}&shotloc=${shotloc}&ctrl=${ctrl}&missed=${missed}";
	print "<a href=\"${me}?${append}\"><img src=$picdir/plus_five2.png></a>";
    }
    if ($num == 1 || $num == 3 || $num == 5) {
	$params = getposparams($num, 3);
	$append = "game=${game}&team=${team}&${params}&shotloc=${shotloc}&ctrl=${ctrl}&missed=${missed}";
	print "<A href=\"${me}?${append}\"><img src=$picdir/plus_three2.png></a>";
    }

    print "</td></tr>\n";
    $params = getnegparams($num);
    $append = "game=${game}&team=${team}&${params}&shotloc=${shotloc}&ctrl=${ctrl}&missed=${missed}";
    print "<tr><td align=center><A href=\"${me}?${append}\"><img src=$picdir/count_down2.png></a>";
    print "</td><td>";
    print "<p style=\"font-size:60px; font-weight:bold\">\n";
    print "$aarray[0]" if ($num == 1);
    print "$tarray[0]" if ($num == 2);
    print "$aarray[1]" if ($num == 3);
    print "$tarray[1]" if ($num == 4);
    print "$aarray[2]" if ($num == 5);
    print "$tarray[2]" if ($num == 6);
    print "</p></td></tr></table>\n";
}

print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head><body bgcolor=\"#dddddd\"><center>\n";

# counter table
print "<table border=0 cellpadding=0 cellspacing=0><tr>\n";
print "<td valign=top>\n";

print "<table border=1 cellpadding=0 cellspacing=0><tr>\n";
print "<th><p style=\"font-size:40px;\">Auto</p></th>\n";
print "</tr><tr><td>\n";
print "<table width=\"100%\" border=0 cellpadding=0 cellspacing=0><tr><td>";
print "<p style=\"font-size:30px;\">Move from<br>Initiation</p></td><td>\n";

my $pargs = "game=${game}&team=${team}&teleop=${teleop}&missed=${missed}&shotloc=${shotloc}&ctrl=${ctrl}";
my $init  = "1";
my $imark = "";
if ($aarray[3] == 1) {
	$init = "0";
    $imark = "_X";
}
my $aargs = "$aarray[0]-$aarray[1]-$aarray[2]-$init";
print "<a href=\"${me}?${pargs}&auto=${aargs}\"><img src=$picdir/box${imark}.png></a>\n";

print "</td></tr></table>";
print "</td></tr><tr><td>\n";
printCounter(1);
print "</td></tr><tr><td>\n";
printCounter(3);
print "</td></tr><tr><td>\n";
printCounter(5);
print "</td></tr></table>\n";

print "</td><td>\n";

print "<table border=1 cellspacing=0 cellpadding=0><tr>\n";
print "<td>\n";

# missed auto counter
print "  <table cellpadding=5 cellspacing=0 border=0><tr>\n";
print "    <th align=center><p style=\"font-size:25px;\">Auto<br>Missed<br>Shots</p></th>";
print "    <td><table cellpadding=5 border=3><tr>\n";
print "      <th bgcolor=white><p style=\"font-size:50px;\">$marray[0]</p></th>\n";
print "     </tr></table></td>\n";
print "   </tr><tr>\n";
my $prefix = "game=${game}&team=${team}&auto=${auto}&teleop=${teleop}&shotloc=${shotloc}&ctrl=${ctrl}";
my $miss = $marray[0] + 1;
print "    <td colspan=2 align=center><a href=\"${me}?${prefix}&missed=${miss}-$marray[1]\"><img height=\"75\" width=\"131\" src=$picdir/count_up2.png><a></td>\n";
print "   </tr><tr>\n";
$miss = $marray[0] - 1;
$miss = 0 if ($miss < 0);
print "    <td colspan=2 align=center><a href=\"${me}?${prefix}&missed=${miss}-$marray[1]\"><img height=\"63\" width=\"121\" src=$picdir/count_down2.png></a></td>\n";
print "   </tr>\n";
print "  </table>\n";

print "</td><td>\n";

# missed teleop counter
print "  <table cellpadding=5 cellspacing=0 border=0><tr>\n";
print "    <th align=center><p style=\"font-size:25px;\">TeleOp<br>Missed<br>Shots</p></th>";
print "    <td><table cellpadding=5 border=3><tr>\n";
print "      <th bgcolor=white><p style=\"font-size:50px;\">$marray[1]</p></th>\n";
print "     </tr></table></td>\n";
print "   </tr><tr>\n";
$prefix = "game=${game}&team=${team}&auto=${auto}&teleop=${teleop}&shotloc=${shotloc}&ctrl=${ctrl}";
$miss = $marray[1] + 1;
print "    <td colspan=2 align=center><a href=\"${me}?${prefix}&missed=$marray[0]-${miss}\"><img height=\"75\" width=\"131\" src=$picdir/count_up2.png><a></td>\n";
print "   </tr><tr>\n";
$miss = $marray[1] - 1;
$miss = 0 if ($miss < 0);
print "    <td colspan=2 align=center><a href=\"${me}?${prefix}&missed=$marray[0]-${miss}\"><img height=\"63\" width=\"121\" src=$picdir/count_down2.png></a></td>\n";
print "   </tr>\n";
print "  </table>\n";

print "</td></tr><tr>\n";
print "<th colspan=2><img src=$picdir/red_power_port2.png></th>\n";

print "</tr></table>\n";

print "</td><td>\n";

print "<table border=1 cellpadding=0 cellspacing=0><tr>\n";
print "<th><p style=\"font-size:60px;\">TeleOp</p></th>\n";
print "</tr><tr><td>\n";
printCounter(2);
print "</td></tr><tr><td>\n";
printCounter(4);
print "</td></tr><tr><td>\n";
printCounter(6);
print "</td></tr></table>\n";

print "</td></tr></table>\n";

print "<center><hr>\n";

# print shot location table
print "<table cellspacing=0 cellpadding=0 border=1 bordercolor=red>\n";
my $index = 0;
for (my $j = 1; $j < 6; $j++) {
    print "<tr>\n";
    for (my $i = 1; $i < 6; $i++) {
	my @tmparr = @sarray;
	my $mark = "";
	if ($tmparr[$index] == 0) {
	    $tmparr[$index] = 1;
	} else {
	    $tmparr[$index] = 0;
	    $mark = "_X";
	}
	my $sstr = join "", @tmparr;
	print "<td><a href=\"${me}?game=${game}&team=${team}&auto=${auto}&teleop=${teleop}&missed=${missed}&ctrl=${ctrl}&shotloc=${sstr}\"><img src=$picdir/left_red_${j}_${i}${mark}.png></td>\n";
	$index++;
    }
    print "</tr>\n";
}
print "</table>\n";
print "<hr>\n";
print "<table cellpadding=3 cellspacing=1 border=1><tr>\n";
print "<td><table cellpadding=1 cellspacing=0 border=0><tr><th><p style=\"font-size:30px;\">Rotational<br>Control</p></th>\n";
my $mark = "";
my $params = "game=${game}&team=${team}&auto=${auto}&teleop=${teleop}&missed=${missed}&shotloc=${shotloc}";
my $append = "ctrl=1$carray[1]";
if ($carray[0] == 1) {
    $mark = "_X";
    $append = "ctrl=0$carray[1]";
}
print "<td><a href=\"${me}?${params}&${append}\"><img src=$picdir/box${mark}.png></a></td></tr></table></td>\n";
print "<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>\n";
print "<td><table cellspacing=0 cellpadding=0 border=0><tr><th><p style=\"font-size:30px;\">Positional<br>Control</p></th>\n";
$mark = "";
$append = "ctrl=$carray[0]1";
if ($carray[1] == 1) {
    $mark = "_X";
    $append = "ctrl=$carray[0]0";
}
print "<td><a href=\"${me}?${params}&${append}\"><img src=$picdir/box${mark}.png></a></td></tr></table></td>\n";
print "<td><p style=\"font-size:20px\"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;";
print "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</p></td>\n";
$append = "ctrl=$ctrl";
print "<th><a href=\"wrapup.cgi?${params}&${append}\"><img height=\"75\" width=\"150\" src=$picdir/next_button.png></a></th>\n";
print "</tr></table>\n";

print "</body>\n";
print "</html>\n";

