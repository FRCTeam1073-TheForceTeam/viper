#!/usr/bin/perl -w

use strict;
use warnings;
use Fcntl qw(:flock SEEK_END);
use CGI;
use lib '../../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;

my $game = $cgi->param('game')||'';
$webutil->error("Bad game parameter", $game) if ($game !~ /^2020[0-9a-zA-Z\-]+_(qm|qf|sm|f)[0-9]+_[RB][1-3]$/);
my $team = $cgi->param('team')||"";
$webutil->error("Bad team parameter", $team) if ($team !~ /^[0-9]+$/);
my $auto = $cgi->param('auto')||"0-0-0-0";
$webutil->error("Bad auto parameter", $auto) if ($auto !~ /^([0-9]+-){3}[0-9]+$/);
my $teleop = $cgi->param('teleop')||"0-0-0";
$webutil->error("Bad teleop parameter", $teleop) if ($teleop !~ /^([0-9]+-){2}[0-9]+$/);
my $missed = $cgi->param('missed')||"0-0";
$webutil->error("Bad missed parameter", $missed) if ($missed !~ /^[0-9]+-[0-9]+$/);
my $shotloc = $cgi->param('shotloc')||"000000000000000000000000000000";
$webutil->error("Bad shotloc parameter", $shotloc) if ($shotloc !~ /^[01]{30}$/);
my $ctrl = $cgi->param('ctrl')||"00";
$webutil->error("Bad ctrl parameter", $ctrl) if ($ctrl !~ /^[01]{2}$/);
my $park = $cgi->param('park')||"0";
$webutil->error("Bad park parameter", $park) if ($park !~ /^[0-9]+$/);
my $climb = $cgi->param('climb')||"0";
$webutil->error("Bad climb parameter", $climb) if ($climb !~ /^[0-9]+$/);
my $bar = $cgi->param('bar')||"0";
$webutil->error("Bad bar parameter", $bar) if ($bar !~ /^[0-9]+$/);
my $buddy = $cgi->param('buddy')||"0";
$webutil->error("Bad buddy parameter", $buddy) if ($buddy !~ /^[0-9]+$/);
my $level = $cgi->param('level')||"0";
$webutil->error("Bad level parameter", $level) if ($level !~ /^[0-9]+$/);
my $defense = $cgi->param('defense')||"0";
$webutil->error("Bad defense parameter", $defense) if ($defense !~ /^[0-9]+$/);
my $defended = $cgi->param('defended')||"0";
$webutil->error("Bad defended parameter", $defended) if ($defended !~ /^[0-9]+$/);
my $fouls = $cgi->param('fouls')||"0";
$webutil->error("Bad fouls parameter", $fouls) if ($fouls !~ /^[0-9]+$/);
my $techfouls = $cgi->param('techfouls')||"0";
$webutil->error("Bad techfouls parameter", $techfouls) if ($techfouls !~ /^[0-9]+$/);
my $rank = $cgi->param('rank')||"0";
$webutil->error("Bad rank parameter", $rank) if ($rank !~ /^[0-9]+$/);
my $scouter = "";$cgi->param('scouter = ')||
$webutil->error("Bad scouter =  parameter", $scouter = ) if ($scouter =  !~ /^[^,\r\n\t]*$/);
my $comments = "";$cgi->param('comments = ')||
$webutil->error("Bad comments =  parameter", $comments = ) if ($comments =  !~ /^[^,\r\n\t]*$/);

my @gdata  = split '_', $game;
my $event  = $gdata[0];
my $match  = $gdata[1];
my $robot  = $gdata[2];
my @marray = split "-", $missed;
my @aarray = split "-", $auto;
my @tarray = split "-", $teleop;
my @sarray = split "", $shotloc;
my @carray = split "", $ctrl;

my $file   = "../data/" . $event . ".scouting.csv";

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
print "Content-type: text/html; charset=UTF-8\n\n";
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
    print "<h1>$err</h1>\n";
    print "<h1>Please Click ";
    print "<a href=\"wrapup.cgi?game=${game}&team=${team}&ctrl=${ctrl}&auto=${auto}&teleop=$teleop&missed=$missed&shotloc=$shotloc\">";
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
