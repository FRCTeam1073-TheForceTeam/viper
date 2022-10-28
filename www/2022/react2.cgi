#!/usr/bin/perl -w

use strict;
use warnings;
use Fcntl qw(:flock SEEK_END);
use CGI;
use lib '../../pm';
use webutil;

my $cgi = CGI->new;

my $game = $cgi->param('game') || '2019UNH_qm1_1';
my $team =  $cgi->param('team') || "1234";

# game elements scouted
my $taxi = $cgi->param('taxi') || 0;
my $human = $cgi->param('human') || 0;
my $alow = $cgi->param('autoLoCount') || 0;
my $ahi = $cgi->param('autoHiCount') || 0;
my $amis = $cgi->param('autoMissed') || 0;
my $abnc = $cgi->param('autoBounce') || 0;
my $tlow = $cgi->param('teleLoCount') || 0;
my $thi = $cgi->param('teleHiCount') || 0;
my $tmis = $cgi->param('teleMissed') || 0;
my $tbnc = $cgi->param('teleBounce') || 0;
my $shub = $cgi->param('shootHub') || 0;
my $sfld = $cgi->param('shootField') || 0;
my $solp = $cgi->param('shootOLP') || 0;
my $swlp = $cgi->param('shootWLP') || 0;
my $rung = $cgi->param('rung') || 0;
my $defense = $cgi->param('defense') || 0;
my $defended = $cgi->param('defended') || 0;
my $fouls = $cgi->param('fouls') || 0;
my $techfouls = $cgi->param('techfouls') || 0;
my $rank = $cgi->param('robot') || 0;
my $scouter = $cgi->param('scouter') || "unknown";  
my $comments = $cgi->param('comments') || "none";

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
    print "<h1>$err</h1>\n";
    print "<h1>Please Click ";
    print "<a href=\"react2.cgi?game=${game}&team=${team}\">";
    print "here</a> to try again</h1>\n";
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
print "<h1>Data for $team in Match $match saved successfully</h1>\n";
print "<h1>Click <a href=\"index.cgi?event=${event}&pos=$pos\">here</a> to proceed to the next match</h1>\n";
print "</body></html>\n";
