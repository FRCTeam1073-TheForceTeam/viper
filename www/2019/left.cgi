#!/usr/bin/perl -w

use strict;
use warnings;

my $me = "left.cgi";
my $height = 125;
my $width = 125;
my $picdir = "/scoutpics";

my $game = '2019UNH_qm1_1';
my $team = '1234';
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

my @gdata  = split '_', $game;
my $event  = $gdata[0];
my $match  = $gdata[1];
my $robot  = $gdata[2];
my @carray = split "", $cargo;
my @rarray = split "", $rocket;
my @harray = split "", $hab;

my $habcolor = "red";
$habcolor = "blue" if ($robot > 3);

sub printcargohatch($) {
	my ($index) = (@_);
	my $val = $carray[$index];
	my @cargoarr = @carray;
	my $cargostr;
	
	if ("$val" eq "0") {
		$cargoarr[$index] = "1";
		$cargostr = join "", @cargoarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargostr}&rocket=${rocket}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/open_hatch_image2.png\"></a></td>\n";
	} elsif ("$val" eq "1") {
		$cargoarr[$index] = "2";
		$cargostr = join "", @cargoarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargostr}&rocket=${rocket}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/hatch_image2.png\"></a></td>\n";
	} elsif ("$val" eq "2") {
		$cargoarr[$index] = "3";
		$cargoarr[$index] = "0" if ($index == 7 || $index == 12);
		$cargostr = join "", @cargoarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargostr}&rocket=${rocket}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/auto_hatch_image2.png\"></a></td>\n";
	} else {
		$cargoarr[$index] = "0";
		$cargostr = join "", @cargoarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargostr}&rocket=${rocket}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/null_hatch_image2.png\"></a></td>\n";
	}
}

sub printcargocargo($) {
	my ($index) = (@_);
	my $val = $carray[$index];
	my @cargoarr = @carray;
	my $cargostr;
	
	if ("$val" eq "0") {
		$cargoarr[$index] = "1";
		$cargostr = join "", @cargoarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargostr}&rocket=${rocket}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/open_cargo_image.png\"></a></td>\n";
	} elsif ("$val" eq "1") {
		$cargoarr[$index] = "2";
		$cargostr = join "", @cargoarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargostr}&rocket=${rocket}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/cargo_image.png\"></a></td>\n";
	} else {
		$cargoarr[$index] = "0";
		$cargostr = join "", @cargoarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargostr}&rocket=${rocket}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/auto_cargo_image.png\"></a></td>\n";
	}
}

sub printrockethatch($) {
	my ($index) = (@_);
	my $val = $rarray[$index];
	my @rocketarr = @rarray;
	my $rocketstr;
	
	if ("$val" eq "0") {
		$rocketarr[$index] = "1";
		$rocketstr = join "", @rocketarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocket=${rocketstr}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/open_hatch_image2.png\"></a></td>\n";
	} elsif ("$val" eq "1") {
		$rocketarr[$index] = "2";
		$rocketstr = join "", @rocketarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocket=${rocketstr}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/hatch_image2.png\"></a></td>\n";
	} else {
		$rocketarr[$index] = "0";
		$rocketstr = join "", @rocketarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocket=${rocketstr}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/auto_hatch_image2.png\"></a></td>\n";
	}
}

sub printrocketcargo($) {
	my ($index) = (@_);
	my $val = $rarray[$index];
	my @rocketarr = @rarray;
	my $rocketstr;
	
	if ("$val" eq "0") {
		$rocketarr[$index] = "1";
		$rocketstr = join "", @rocketarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocket=${rocketstr}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/open_cargo_image.png\"></a></td>\n";
	} elsif ("$val" eq "1") {
		$rocketarr[$index] = "2";
		$rocketstr = join "", @rocketarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocket=${rocketstr}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/cargo_image.png\"></a></td>\n";
	} else {
		$rocketarr[$index] = "0";
		$rocketstr = join "", @rocketarr;
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocket=${rocketstr}\">";
		print "<img height=\"$height\" width=\"$width\" "; 
		print "src=\"$picdir/auto_cargo_image.png\"></a></td>\n";
	}
}

sub printStartLevel {

	print "<table border=1 cellpadding=0 cellspacing=0><tr>\n";
	print "<th colspan=3 align=center>Starting Position</th></tr><tr>\n";

	if ($harray[0] == 1) {
		my $myhab = "0" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_habx.png\"></a></td>\n";
	} else {
		my $myhab = "1" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_hab.png\"></a></td>\n";
	}
	
	print "<td><img src=\"$picdir/top_${habcolor}_hab.png\"></td>\n";
	
	if ($harray[0] == 2) {
		my $myhab = "0" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_habx.png\"></a></td>\n";
	} else {
		my $myhab = "2" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_hab.png\"></a></td>\n";
	}
	
	print "</tr><tr>\n";
	
	if ($harray[0] == 3) {
		my $myhab = "0" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_left_${habcolor}_habx.png\"></a></td>\n";
	} else {
		my $myhab = "3" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_left_${habcolor}_hab.png\"></a></td>\n";
	}
	
	if ($harray[0] == 4) {
		my $myhab = "0" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_${habcolor}_habx.png\"></a></td>\n";
	} else {
		my $myhab = "4" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_${habcolor}_hab.png\"></a></td>\n";
	}
	
	if ($harray[0] == 5) {
		my $myhab = "0" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_right_${habcolor}_habx.png\"></a></td>\n";
	} else {
		my $myhab = "5" . $harray[1];
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_right_${habcolor}_hab.png\"></a></td>\n";
	}
	
	print "</tr></table>\n";
}

sub printEndLevel {

	print "<table border=1 cellpadding=0 cellspacing=0><tr>\n";
	print "<th colspan=3 align=center>EndGame</th></tr><tr>\n";

	if ($harray[1] == 1) {
		my $myhab = $harray[0] . "0";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_habx.png\"></a></td>\n";
	} else {
		my $myhab = $harray[0] . "1";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_hab.png\"></a></td>\n";
	}

	if ($harray[1] == 2) {
		my $myhab = $harray[0] . "0";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/top_${habcolor}_habx.png\"></a></td>\n";
	} else {
		my $myhab = $harray[0] . "2";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/top_${habcolor}_hab.png\"></a></td>\n";
	}

	if ($harray[1] == 3) {
		my $myhab = $harray[0] . "0";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_habx.png\"></a></td>\n";
	} else {
		my $myhab = $harray[0] . "3";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/left_${habcolor}6_hab.png\"></a></td>\n";
	}

	print "</tr><tr>\n";

	if ($harray[1] == 4) {
		my $myhab = $harray[0] . "0";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_left_${habcolor}_habx.png\"></a></td>\n";
	} else {
		my $myhab = $harray[0] . "4";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_left_${habcolor}_hab.png\"></a></td>\n";
	}

	if ($harray[1] == 5) {
		my $myhab = $harray[0] . "0";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_${habcolor}_habx.png\"></a></td>\n";
	} else {
		my $myhab = $harray[0] . "5";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_${habcolor}_hab.png\"></a></td>\n";
	}

	if ($harray[1] == 6) {
		my $myhab = $harray[0] . "0";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_right_${habcolor}_habx.png\"></a></td>\n";
	} else {
		my $myhab = $harray[0] . "6";
		print "<td><a href=\"${me}?game=${game}&team=${team}&hab=${myhab}&cargo=${cargo}&rocket=${rocket}\">";
		print "<img src=\"$picdir/bot_right_${habcolor}_hab.png\"></a></td>\n";
	}
	print "</tr></table>\n";

}

sub getpos {
	my ($pos) = (@_);
	return "R1" if ($pos == 1);
	return "R2" if ($pos == 2);
	return "R3" if ($pos == 3);
	return "B1" if ($pos == 4);
	return "B2" if ($pos == 5);
	return "B3" if ($pos == 6);
	return "X";
}


print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head><body bgcolor=\"#dddddd\">\n";
#if ($robot < 4) {
#	print "<body bgcolor=\"#ff6666\">\n";
#} else {
#	print "<body bgcolor=\"#99ccff\">\n";
#}

# master table
print "<table border=0 cellpadding=0 cellspacing=0><tr>";
print "<td align=right valign=center>\n";

# print container for spacing top rocket
print "<table border=0 cellpadding=0 cellspacing=20><tr><td>\n";
#
# print top rocket
#
print "<table border=0 cellpadding=0 cellspacing=0><tr>\n";
print "<td colspan=4 align=center><p><B>Far Rocket Top</B></p></td></tr><tr>\n";
printrockethatch(0);
printrocketcargo(1);
printrocketcargo(2);
printrockethatch(3);
print "</tr><tr>\n";
printrockethatch(4);
printrocketcargo(5);
printrocketcargo(6);
printrockethatch(7);
print "</tr><tr>\n";
printrockethatch(8);
printrocketcargo(9);
printrocketcargo(10);
printrockethatch(11);
print "</tr><tr><td colspan=4 align=center><p><B>Far Rocket Bottom</B></p></td>";
print "</tr></table>";

# close up container
print "</td></tr></table>\n";

#
# print cargo ship head
#
print "<table border=0 cellpadding=0 cellspacing=0><tr>\n";

my $pos = getpos $robot;
print "<td align=center BGCOLOR=\"d6d4d3\"><p style=\"font-size:50px; font-weight:bold;\">";
print "&nbsp;&nbsp;$team&nbsp;&nbsp;</p></td>\n";
print "<td><p>&nbsp;&nbsp;&nbsp;&nbsp;</p></td>\n";
printcargohatch(7);
printcargocargo(6);

print "</tr><tr>\n";

print "<td align=center BGCOLOR=\"grey\">\n";
print "<B><A href=\"wrapup.cgi?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocket=${rocket}\">";
print "<img height=\"50\" width=\"100\" src=\"$picdir/next_button.png\"></a></td>\n";
print "<td><p>&nbsp;</p></td>\n";
printcargohatch(12);
printcargocargo(11);

print "</tr></table>\n";

# print container for spacing bottom rocket
print "<table border=0 celpadding=0 cellspacing=20><tr><td>\n";

# print bottom rocket
print "<table border=0 cellpadding=0 cellspacing=0><tr>\n";
print "<td colspan=4 align=center><p><B>Near Rocket Top</B></p></td></tr><tr>";
printrockethatch(12);
printrocketcargo(13);
printrocketcargo(14);
printrockethatch(15);
print "</tr><tr>\n";
printrockethatch(16);
printrocketcargo(17);
printrocketcargo(18);
printrockethatch(19);
print "</tr><tr>\n";
printrockethatch(20);
printrocketcargo(21);
printrocketcargo(22);
printrockethatch(23);
print "</tr><tr><td colspan=4 align=center><p><B>Near Rocket Bottom</B></p></td>";
print "</tr></table>\n";

# close up container
print "</td></tr></table>\n";

# master table
print "</td><td align=center valign=center>\n";

printStartLevel();
print "<br>\n";
#
# print cargo ship body
#
print "<table border=0 cellpadding=0 cellspacing=0><tr>\n";
printcargohatch(0);
printcargohatch(1);
printcargohatch(2);
print "</tr><tr>\n";
printcargocargo(3);
printcargocargo(4);
printcargocargo(5);
print "</tr><tr>\n";
printcargocargo(8);
printcargocargo(9);
printcargocargo(10);
print "</tr><tr>\n";
printcargohatch(13);
printcargohatch(14);
printcargohatch(15);
print "</tr></table>";
print "<br>\n";

printEndLevel();

# master table
print "</td></tr></table>\n";

print "</body>\n";
print "</html>\n";

