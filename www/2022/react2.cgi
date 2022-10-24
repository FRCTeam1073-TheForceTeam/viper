#!/usr/bin/perl -w

use strict;
use warnings;

use Fcntl qw(:flock SEEK_END);


my $game = '2019UNH_qm1_1';
my $team = "1234";

# game elements scouted
my $taxi = 0;
my $human = 0;
my $alow = 0;
my $ahi = 0;
my $amis = 0;
my $abnc = 0;
my $tlow = 0;
my $thi = 0;
my $tmis = 0;
my $tbnc = 0;
my $shub = 0;
my $sfld = 0;
my $solp = 0;
my $swlp = 0;
my $rung = 0;
my $defense = 0;
my $defended = 0;
my $fouls = 0;
my $techfouls = 0;
my $rank = 0;
my $scouter = "unknown";
my $comments = "none";

#
# read in previous game state
#
my %params;
if (exists $ENV{'QUERY_STRING'}) {
    my @args = split /\&/, $ENV{'QUERY_STRING'};
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
}

if (exists $ENV{'CONTENT_LENGTH'}) {
    my $content = $ENV{'CONTENT_LENGTH'};
    if ($content > 0) {
	my $data = <STDIN>;
	my @args = split /\&/, $data;
	foreach my $arg (@args) {
	    my @bits = split /=/, $arg;
	    next unless (@bits == 2);
	    $params{$bits[0]} = $bits[1];
	}
    }
}

$game    = $params{'game'}    if (defined $params{'game'});
$team    = $params{'team'}    if (defined $params{'team'});

# game elements
$taxi  = $params{'taxi'}  if (defined $params{'taxi'});
$human = $params{'human'} if (defined $params{'human'});
$alow  = $params{'autoLoCount'}  if (defined $params{'autoLoCount'});
$ahi   = $params{'autoHiCount'}   if (defined $params{'autoHiCount'});
$amis  = $params{'autoMissed'}  if (defined $params{'autoMissed'});
$abnc  = $params{'autoBounce'}  if (defined $params{'autoBounce'});
$tlow  = $params{'teleLoCount'}  if (defined $params{'teleLoCount'});
$thi   = $params{'teleHiCount'}   if (defined $params{'teleHiCount'});
$tmis  = $params{'teleMissed'}  if (defined $params{'teleMissed'});
$tbnc  = $params{'teleBounce'}  if (defined $params{'teleBounce'});
$shub  = $params{'shootHub'}  if (defined $params{'shootHub'});
$sfld  = $params{'shootField'}  if (defined $params{'shootField'});
$solp  = $params{'shootOLP'}  if (defined $params{'shootOLP'});
$swlp  = $params{'shootWLP'}  if (defined $params{'shootWLP'});
$rung  = $params{'rung'}  if (defined $params{'rung'});

$defense   = $params{'defense'}   if (defined $params{'defense'});
$defended  = $params{'defended'}  if (defined $params{'defended'});
$fouls     = $params{'fouls'}     if (defined $params{'fouls'});
$techfouls = $params{'techfouls'} if (defined $params{'techfouls'});
$rank      = $params{'robot'}     if (defined $params{'robot'});
$scouter   = $params{'scouter'}   if (defined $params{'scouter'});
$comments  = $params{'comments'}  if (defined $params{'comments'});

#
# process/store the scouting data
#
my @gdata  = split '_', $game;
my $event  = $gdata[0];
my $match  = $gdata[1];
my $robot  = $gdata[2];

my $file   = "../data/" . $event . ".txt";

sub getheader {
    my $header0 = "event,match,team";
    my $header1 = "taxi,human,auto_low_hub,auto_high_hub,auto_missed,auto_bounce_out";
    my $header2 = "teleop_low_hub,teleop_high_hub,teleop_missed,teleop_bounce_out";
    my $header3 = "shoot_from_hub,shoot_from_field,shoot_from_outer_LP,shoot_from_wallLP";
    my $header4 = "rung";
    my $header5 = "defense,defended,fouls,techfouls,rank,scouter,comments";
    
    return "$header0,$header1,$header2,$header3,$header4,$header5";
}


sub dumpdata {
    my $str = "$event,$match,$team,";
    # auto
    $str .= "$taxi,$human,$alow,$ahi,$amis,$abnc,";
    # teleop
    $str .= "$tlow,$thi,$tmis,$tbnc,";
    # shoot from
    $str .= "$shub,$sfld,$solp,$swlp,";
    # hung from rung
    $str .= "$rung,";
    # defense and fouls
    $str .= "$defense,$defended,$fouls,$techfouls,$rank";
    # add scouter and comments but replace all commas with underscores
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
print "Content-type: text/html; charset=UTF-8\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
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
    print "<a href=\"react2.cgi?game=${game}&team=${team}\">";
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
