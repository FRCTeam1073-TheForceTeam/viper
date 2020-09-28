#!/usr/bin/perl -w

use strict;
use warnings;
use Fcntl qw(:flock SEEK_END);


my $game = '2019UNH_qm1_1';
my $team = "1234";
my $auto = "0-0-0";
my $teleop = "0-0-0";
my $missed = "0-0";
my $shotloc = "0000000000000000000000000";
my $ctrl = "00";

my $park = "0";
my $climb = "0";
my $bar = "0";
my $buddy = "0";
my $level = "0";
my $defense = "0";
my $defended = "0";
my $fouls = "0";
my $techfouls = "0";
my $rank = "0";
my $scouter = "";
my $comments = "";

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
    $game      = $params{'game'}      if (defined $params{'game'});
    $team      = $params{'team'}      if (defined $params{'team'});
    $auto      = $params{'auto'}      if (defined $params{'auto'});
    $teleop    = $params{'teleop'}    if (defined $params{'teleop'});
    $missed    = $params{'missed'}    if (defined $params{'missed'});
    $shotloc   = $params{'shotloc'}   if (defined $params{'shotloc'});
    $ctrl      = $params{'ctrl'}      if (defined $params{'ctrl'});
    $park      = $params{'park'}      if (defined $params{'park'});
    $climb     = $params{'climb'}     if (defined $params{'climb'});
    $bar       = $params{'bar'}       if (defined $params{'bar'});
    $buddy     = $params{'buddy'}     if (defined $params{'buddy'});
    $level     = $params{'level'}     if (defined $params{'level'});
    $defense   = $params{'defense'}   if (defined $params{'defense'});
    $defended  = $params{'defended'}  if (defined $params{'defended'});
    $fouls     = $params{'fouls'}     if (defined $params{'fouls'});
    $techfouls = $params{'techfouls'} if (defined $params{'techfouls'});
    $rank      = $params{'rank'}      if (defined $params{'rank'});
    $scouter   = $params{'scouter'}   if (defined $params{'scouter'});
    $comments  = $params{'comments'}  if (defined $params{'comments'});
}

my @gdata  = split '_', $game;
my $event  = $gdata[0];
my $match  = $gdata[1];
my $robot  = $gdata[2];
my @marray = split "-", $missed;
my @aarray = split "-", $auto;
my @tarray = split "-", $teleop;
my @sarray = split "", $shotloc;
my @carray = split "", $ctrl;

my $file   = "/var/www/html/csv/" . $event . ".txt";

sub getheader {
    my $header0 = "event,match,team";
    my $header1 = "auto_line,auto_bottom,auto_outer,auto_inner";
    my $header2 = "teleop_bottom,teleop_outer,teleop_inner,auto_missed,teleop_missed";
    my $header3 = "shotlocA1,shotlocA2,shotlocA3,shotlocA4,shotlocA5";
    my $header4 = "shotlocB1,shotlocB2,shotlocB3,shotlocB4,shotlocB5";
    my $header5 = "shotlocC1,shotlocC2,shotlocC3,shotlocC4,shotlocC5";
    my $header6 = "shotlocD1,shotlocD2,shotlocD3,shotlocD4,shotlocD5";
    my $header7 = "shotlocE1,shotlocE2,shotlocE3,shotlocE4,shotlocE5";
    my $header8 = "rotation_control,position_control";
    my $header9 = "parked,climbed,bar_position,buddylift,leveled";
    my $headerA = "defense,defended,fouls,techfouls,rank,scouter,comments";
    
    return "$header0,$header1,$header2,$header3,$header4,$header5,$header6,$header7,$header8,$header9,$headerA";
}


sub dumpdata {
    my $str = "$event,$match,$team,";
    # power cell counters
    $str .= "$aarray[3],$aarray[2],$aarray[1],$aarray[0],";
    $str .= "$tarray[2],$tarray[1],$tarray[0],$marray[0],$marray[1],";
    # shot location
    $str .= "$sarray[0],$sarray[1],$sarray[2],$sarray[3],$sarray[4],";
    $str .= "$sarray[5],$sarray[6],$sarray[7],$sarray[8],$sarray[9],";
    $str .= "$sarray[10],$sarray[11],$sarray[12],$sarray[13],$sarray[14],";
    $str .= "$sarray[15],$sarray[16],$sarray[17],$sarray[18],$sarray[19],";
    $str .= "$sarray[20],$sarray[21],$sarray[22],$sarray[23],$sarray[24],";
    # control panel
    $str .= "$carray[0],$carray[1],";
    # end game
    $str .= "$park,$climb,$bar,$buddy,$level,";
    # defense and fouls
    $str .= "$defense,$defended,$fouls,$techfouls,$rank";
    # add scouter and comments but replace all comments with underscores
    $scouter =~ tr/,/_/;
    $comments =~ tr/,/_/;
    $str .= ",$scouter,$comments";

    return $str;
}

my $header = getheader();
my $dline = dumpdata();

sub writeFile {
    my $errstr = "";
	
    if (! -f $file) {
	`touch $file`;
    }
    if (open my $fh, '+<', $file) {
	if (flock ($fh, LOCK_EX)) {
	    my $first = <$fh>;
	    if (!defined $first) {
		print $fh "$header\n";
	    }
	    seek $fh, 0, SEEK_END;
	    print $fh "$dline\n";
	} else {
	    $errstr = "failed to lock $file: $!\n";
	}
	close $fh;
    } else {
	$errstr = "failed to open $file: $!\n";
    }
    return $errstr;
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";

my @fcheck = split /\s+/, $file;
if (@fcheck > 1) {
    print "<p>ARG ERROR</p>\n";
    print "</bpdy></html>\n";
    exit 0;
}
my $err = writeFile();

if ($err ne "") {
    # print error, please try again
    print "<H1>$err</H1>\n";
    print "<H1>Please Click ";
    print "<a href=\"wrapup.cgi?game=${game}&team=${team}&ctrl=${ctrl}&auto=${auto}&teleop=$teleop&missed=$missed&shotloc=$shotloc\">";
    print "here</a> to try again</H1>\n";
    print "</body></html>\n";
    exit 0;
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

my $pos = getpos $robot;

print "<br><br><br>";
print "<H1>Data for $team in Match $match saved successfully</H1>\n";
print "<H1>Click <a href=\"index.cgi?event=${event}&pos=$pos\">here</a> to proceed to the next match</H1>\n";
print "</body></html>\n";
