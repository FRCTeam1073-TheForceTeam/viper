#!/usr/bin/perl -w

use strict;
use warnings;
use Fcntl qw(:flock SEEK_END);


my $game = '2019UNH_qm1_1';
my $team = "1234";
my $cargo = "0000000000000000";
my $rocket = "000000000000000000000000";
my $hab = "00";
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
    $cargo     = $params{'cargo'}     if (defined $params{'cargo'});
    $rocket    = $params{'rocket'}    if (defined $params{'rocket'});
    $hab       = $params{'hab'}       if (defined $params{'hab'});
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
my @carray = split "", $cargo;
my @rarray = split "", $rocket;
my @harray = split "", $hab;

my $file   = "/var/www/html/csv/" . $event . ".txt";

sub getheader {
    my $header0 = "event,match,team,startlevel";
    my $header1 = "total_hatches,total_cargo,end_level";
    my $header2 = "auto_hatch_cs,auto_cargo_cs";
    my $header3 = "auto_hatch_topr,auto_hatch_midr,auto_hatch_botr";
    my $header4 = "auto_cargo_topr,auto_cargo_midr,auto_cargo_botr";
    my $header5 = "hatch_cs,hatch_topr,hatch_midr,hatch_botr";
    my $header6 = "cargo_cs,cargo_topr,cargo_midr,cargo_botr";
    my $header7 = "defense,defended,fouls,techfouls,rank,scouter,comments";
    
    return "$header0,$header1,$header2,$header3,$header4,$header5,$header6,$header7";
}


sub dumpdata {
    my $str = "$event,$match,$team,";
	# starting position:harray[0]: 1|2 = 2, else = 1
    if ($harray[0] eq "1" || $harray[0] eq "2") {
	$str .= "2,";
    } else {
	$str .= "1,";
    }
    #compute values
    my $ahcs = 0;
    my $accs = 0;
    my $ahr1 = 0;
    my $ahr2 = 0;
    my $ahr3 = 0;
    my $acr1 = 0;
    my $acr2 = 0;
    my $acr3 = 0;
    my $hcs = 0;
    my $ccs = 0;
    my $hr1 = 0;
    my $hr2 = 0;
    my $hr3 = 0;
    my $cr1 = 0;
    my $cr2 = 0;
    my $cr3 = 0;
    #cargo hatches
    foreach my $i (0,1,2,7,12,13,14,15) {
	$hcs++  if ($carray[$i] == 1);
	$ahcs++ if ($carray[$i] == 2);
    }
    #cargo cargo
    foreach my $i (3,4,5,6,8,9,10,11) {
	$ccs++  if ($carray[$i] == 1);
	$accs++ if ($carray[$i] == 2);
    }
    #rocket 1 hatches
    foreach my $i (0,3,12,15) {
	$hr1++  if ($rarray[$i] == 1);
	$ahr1++ if ($rarray[$i] == 2);
    }
    #rocket 2 hatches
    foreach my $i (4,7,16,19) {
	$hr2++  if ($rarray[$i] == 1);
	$ahr2++ if ($rarray[$i] == 2);
    }
    #rocket 3 hatches
    foreach my $i (8,11,20,23) {
	$hr3++  if ($rarray[$i] == 1);
	$ahr3++ if ($rarray[$i] == 2);
    }
    #rocket 1 cargo
    foreach my $i (1,2,13,14) {
	$cr1++  if ($rarray[$i] == 1);
	$acr1++ if ($rarray[$i] == 2);
    }
    #rocket 2 cargo
    foreach my $i (5,6,17,18) {
	$cr2++  if ($rarray[$i] == 1);
	$acr2++ if ($rarray[$i] == 2);
    }
    #rocket 3 cargo
    foreach my $i (9,10,21,22) {
	$cr3++  if ($rarray[$i] == 1);
	$acr3++ if ($rarray[$i] == 2);
    }
    # total hatches, total cargo
    my $th = $hcs + $ahcs + $hr1 + $ahr1 + $hr2 + $ahr2 + $hr3 + $ahr3;
    my $tc = $ccs + $accs + $cr1 + $acr1 + $cr2 + $acr2 + $cr3 + $acr3;
    $str .= "$th,$tc,";
	# ending position:harray[1]: 2=3, 1|3=2, 4|5|6=1, else 0
	my $endpos = "0";
    if ($harray[1] eq "2") {
	$endpos = "3";
    }
    if ($harray[1] eq "1" || $harray[1] eq "3") {
	$endpos = "2";
    }
    if ($harray[1] eq "4" || $harray[1] eq "5" || $harray[1] eq "6") {
	$endpos = "1";
    }
	$str .= "$endpos,";
	# autonomous
    $str .= "$ahcs,$accs,";
    $str .= "$ahr1,$ahr2,$ahr3,";
    $str .= "$acr1,$acr2,$acr3,";
	# teleop hatches
    $str .= "$hcs,$hr1,$hr2,$hr3,";
    # teleop cargo
	$str .= "$ccs,$cr1,$cr2,$cr3,";
    # extras
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
    print "<a href=\"score.cgi?game=${game}&team=${team}&hab=${hab}&cargo=${cargo}&rocke$rocket\">";
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
