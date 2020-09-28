#!/usr/bin/perl -w

use strict;
use warnings;

my $event = "";
my $me = "select.cgi";
my $a1 = "";
my $a2 = "";
my $a3 = "";
my $a4 = "";
my $a5 = "";
my $a6 = "";
my $a7 = "";
my $a8 = "";
my $s1 = "";
my $s2 = "";
my $s3 = "";
my $s4 = "";
my $save = "";
my $reset = "";
# start with 1st alliance captain
my $pos = 1;

#
# read in given game data
#
if ($ENV{QUERY_STRING}) {
    my @args = split /\&/, $ENV{QUERY_STRING};
    my %params;
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
    $event = $params{'event'}  if (defined $params{'event'});
    $a1 = $params{'a1'} if (defined $params{'a1'});
    $a2 = $params{'a2'} if (defined $params{'a2'});
    $a3 = $params{'a3'} if (defined $params{'a3'});
    $a4 = $params{'a4'} if (defined $params{'a4'});
    $a5 = $params{'a5'} if (defined $params{'a5'});
    $a6 = $params{'a6'} if (defined $params{'a6'});
    $a7 = $params{'a7'} if (defined $params{'a7'});
    $a8 = $params{'a8'} if (defined $params{'a8'});
    $save = $params{'save'} if (defined $params{'save'});
    $pos = $params{'pos'} if (defined $params{'pos'});
    $s1 = $params{'s1'} if (defined $params{'s1'});
    $s2 = $params{'s2'} if (defined $params{'s2'});
    $s3 = $params{'s3'} if (defined $params{'s3'});
    $s4 = $params{'s4'} if (defined $params{'s4'});
    $reset = $params{'reset'} if (defined $params{'reset'});
}

my @aa1 = split /-/, $a1;
my @aa2 = split /-/, $a2;
my @aa3 = split /-/, $a3;
my @aa4 = split /-/, $a4;
my @aa5 = split /-/, $a5;
my @aa6 = split /-/, $a6;
my @aa7 = split /-/, $a7;
my @aa8 = split /-/, $a8;

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";
print "<table cellpadding=2 border=0><tr><td>";
print "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td><th>";
print "<H1>Alliance Selection</H1>\n";
print "</th><td>";
print "<p>&nbsp; &nbsp; &nbsp;<a href=\"/index.html\">Home</a></p>\n";
print "</td></tr></table>\n";


if ($event eq "") {
    my $events = `ls -1 matchdata/*.dat`;
    my @files = split /\n/, $events;

    if (@files < 1 ) {
	print "<p>There are no event files found</p>\n";
	print "</body></html>\n";
	exit 0;
    }

    print "<H2>Select an event:</H2>";
    print "<table cellpadding=5 cellspacing=5 border=0>\n";
    foreach my $f (@files) {
	my @fname = split /\//, $f;
	my @name = split /\./, $fname[-1];
	print "<tr><th><h3><a href=\"${me}?event=$name[0]\">$name[0]</a></h3></td></tr>\n";
    }
    print "</table>\n";
    print "</body></html>\n";
    exit 0;
}

# we have an event: check if alliances already configured
my $efile = "/var/www/cgi-bin/matchdata/${event}.elims";
if (-f $efile) {
    # has a reset been requested?
    if ($reset ne "") {
	my $output = `rm -f $efile 2>&1`;
	if ($? != 0) {
	    print "<h2>Error removing $efile: $output</h2>\n";
	} else {
	    print "<h2>Alliances for $event have been deleted</h2>\n";
	}
	print "<h2>Click <a href=\"${me}?event=$event\">here</a> to continue.</h2>\n";
	print "</body></html>\n";
	exit 0;
    }

    # load alliances
    my @alliances;
    if (open my $fh, "<", $efile) {
	while (my $line = <$fh>) {
	    chomp $line;
	    push @alliances, $line;
	}
	close $fh;
    } else {
	print "<H2>Error opening $efile: $!</H2>\n";
	print "</body></html>\n";
	exit 0;
    }
    
    # are we saving semifinals?
    if ($save ne "") {
	my $sfile = "/var/www/cgi-bin/matchdata/${event}.semis";
	if (open my $fh, ">", $sfile) {
	    print $fh "$alliances[${s1}-1]\n";
	    print $fh "$alliances[${s2}-1]\n";
	    print $fh "$alliances[${s3}-1]\n";
	    print $fh "$alliances[${s4}-1]\n";
	    close $fh;
	} else {
	    print "<p>Error, could not open $sfile for writing: $!.</p>";
	    print "</body></html>\n";
	    exit 0;
	}

	print "<h2>Semifinal teams saved</h2>\n";
	print "<table cellpadding=5 cellspacing=5 border=0>\n";
	print "<tr><th>$alliances[${s1}-1]</th><td align=left>\\</td></tr>\n";
	print "<tr><td>&nbsp;</td><td>&nbsp;------------------</td></tr>\n";
	print "<tr><th>$alliances[${s2}-1]</th><td align=left>/</td></tr>\n";
	print "<tr><td colspan=2><hr></td></tr>\n";
	print "<tr><th>$alliances[${s3}-1]</th><td align=left>\\</td></tr>\n";
	print "<tr><td>&nbsp;</td><td>&nbsp;------------------</td></tr>\n";
	print "<tr><th>$alliances[${s4}-1]</th><td align=left>/</td></tr>\n";
	
	print "</body></html>\n";
	exit 0;
    }
    
    # configure semifinals
    print "<h2><a href=\"${me}?event=$event&reset=1\">Reset</A> Alliances or Select Quarterfinal Winners</h2>\n";
    print "<table cellpadding=5 cellspacing=5 border=0>";
    print "<tr><th>1</th><th>";
    if ("$s1" eq "1") {
	print "$alliances[0]";
    } else {
	print "<a href=\"${me}?event=$event&s1=1&s2=$s2&s3=$s3&s4=$s4\">$alliances[0]</a>";
    }
    print "</th><td align=left>\\</td></tr>";
    print "<tr><td>&nbsp;</td><td>&nbsp;</td><th>";
    if ($s1 ne "") {
	if ("$s1" eq "1") {
	    print "$alliances[0]";
	} else {
	    print "$alliances[7]";
	}
    } else {
	print "&nbsp;------------------";
    }
    print "</th></tr>\n";
    print "<tr><th>8</th><th>";
    if ("$s1" eq "8") {
	print "$alliances[7]";
    } else {
	print "<a href=\"${me}?event=$event&s1=8&s2=$s2&s3=$s3&s4=$s4\">$alliances[7]</a>";
    }
    print "</th><td align=left>/</td></tr>";
    print "<tr><td colspan=3><hr></td></tr>\n";
    print "<tr><th>4</th><th>";
    if ("$s2" eq "4") {
	print "$alliances[3]";
    } else {
	print "<a href=\"${me}?event=$event&s1=$s1&s2=4&s3=$s3&s4=$s4\">$alliances[3]</a>";
    }
    print "</th><td align=left>\\</td></tr>";
    print "<tr><td>&nbsp;</td><td>&nbsp;</td><th>";
    if ($s2 ne "") {
	if ("$s2" eq "4") {
	    print "$alliances[3]";
	} else {
	    print "$alliances[4]";
	}
    } else {
	print "&nbsp;------------------";
    }
    print "</th></tr>\n";
    print "<tr><th>5</th><th>";
    if ("$s2" eq "5") {
	print "$alliances[4]";
    } else {
	print "<a href=\"${me}?event=$event&s1=$s1&s2=5&s3=$s3&s4=$s4\">$alliances[4]</a>";
    }
    print "</th><td align=left>/</td></tr>";
    print "<tr><td colspan=3><hr></td></tr>\n";
    print "<tr><th>2</th><th>";
    if ("$s3" eq "2") {
	print "$alliances[1]";
    } else {
	print "<a href=\"${me}?event=$event&s1=$s1&s2=$s2&s3=2&s4=$s4\">$alliances[1]</a>";
    }
    print "</th><td align=left>\\</td></tr>";
    print "<tr><td>&nbsp;</td><td>&nbsp;</td><th>";
    if ($s3 ne "") {
	if ("$s3" eq "2") {
	    print "$alliances[1]";
	} else {
	    print "$alliances[6]";
	}
    } else {
	print "&nbsp;------------------";
    }
    print "</th></tr>\n";
    print "<tr><th>7</th><th>";
    if ("$s3" eq "7") {
	print "$alliances[6]";
    } else {
	print "<a href=\"${me}?event=$event&s1=$s1&s2=$s2&s3=7&s4=$s4\">$alliances[6]</a>";
    }
    print "</th><td align=left>/</td></tr>";
    print "<tr><td colspan=3><hr></td></tr>\n";
    print "<tr><th>3</th><th>";
    if ("$s4" eq "3") {
	print "$alliances[2]";
    } else {
	print "<a href=\"${me}?event=$event&s1=$s1&s2=$s2&s3=$s3&s4=3\">$alliances[2]</a>";
    }
    print "</th><td align=left>\\</td></tr>";
    print "<tr><td>&nbsp;</td><td>&nbsp;</td><th>";
    if ($s4 ne "") {
	if ("$s4" eq "3") {
	    print "$alliances[2]";
	} else {
	    print "$alliances[5]";
	}
    } else {
	print "&nbsp;------------------";
    }
    print "</th></tr>\n";
    print "<tr><th>6</th><th>";
    if ("$s4" eq "6") {
	print "$alliances[5]";
    } else {
	print "<a href=\"${me}?event=$event&s1=$s1&s2=$s2&s3=$s3&s4=6\">$alliances[5]</a>";
    }
    print "</th><td align=left>/</td></tr>";
    print "</table>\n";
    # can we save yet?
    if ("$s1" ne "" && "$s2" ne "" && "$s3" ne "" && "$s4" ne "") {
	print "<br><H2><a href=\"${me}?event=${event}&s1=$s1&s2=$s2&s3=$s3&s4=$s4&save=yes\">Save</a> Semifinal Matches</H2>\n";
    }
    print "</body></html>\n";
    exit 0;
}

#
# Load match data to get team list
#
my $file = "/var/www/cgi-bin/matchdata/${event}.dat";
if (! -f $file) {
    print "<H2>Error, file $file does not exist</H2>\n";
    print "</body></html>\n";
    exit 0;
}

my %teamlist;

if ( open(my $fh, "<", $file) ) {
    while (my $line = <$fh>) {
	my @items = split /\s+/, $line;
	next if (@items != 3);
	$teamlist{$items[2]} = 1;
    }
    close $fh;
} else {
    print "<H2>Error, could not open $file: $!</H2>\n";
    print "</body></html>\n";
    exit 0;
}


if ("$save" ne "") {
    # Here we are saving to a file
    my $file = "/var/www/cgi-bin/matchdata/${event}.elims";
    if (open my $fh, ">", $file) {
	print $fh "$a1\n";
	print $fh "$a2\n";
	print $fh "$a3\n";
	print $fh "$a4\n";
	print $fh "$a5\n";
	print $fh "$a6\n";
	print $fh "$a7\n";
	print $fh "$a8\n";
	close $fh;
    } else {
	print "<p>Error, could not open $file for writing: $!.</p>";
	print "</body></html>\n";
    }

    print "<p>Alliance 1: $a1</p>\n";
    print "<p>Alliance 2: $a2</p>\n";
    print "<p>Alliance 3: $a3</p>\n";
    print "<p>Alliance 4: $a4</p>\n";
    print "<p>Alliance 5: $a5</p>\n";
    print "<p>Alliance 6: $a6</p>\n";
    print "<p>Alliance 7: $a7</p>\n";
    print "<p>Alliance 8: $a8</p>\n";

    print "<h3>Elimination Matches are now available for $event</h3>\n";
    print "</body></html>\n";
    exit 0;
}

# Position map
#  1  2 24 25
#  3  4 23 26
#  5  6 22 27
#  7  8 21 28
#  9 10 20 29
# 11 12 19 30
# 13 14 18 31
# 15 16 17 32

my $npos = $pos + 1;
my $link = "${me}?event=${event}&pos=${npos}";

# craft the alliance link but skip the given alliance
sub makealink {
    my ($num) = (@_);
    my $str = "";
    $str .= "a1=$a1" if ($num != 1);
    if ($num != 2 && "$a2" ne "") {
	$str .= "&" if ("$str" ne "");
	$str .= "a2=$a2";
    }
    if ($num != 3 && "$a3" ne "") {
	$str .= "&" if ("$str" ne "");
	$str .= "a3=$a3";
    }
    if ($num != 4 && "$a4" ne "") {
	$str .= "&" if ("$str" ne "");
	$str .= "a4=$a4";
    }
    if ($num != 5 && "$a5" ne "") {
	$str .= "&" if ("$str" ne "");
	$str .= "a5=$a5";
    }
    if ($num != 6 && "$a6" ne "") {
	$str .= "&" if ("$str" ne "");
	$str .= "a6=$a6";
    }
    if ($num != 7 && "$a7" ne "") {
	$str .= "&" if ("$str" ne "");
	$str .= "a7=$a7";
    }
    if ($num != 8 && "$a8" ne "") {
	$str .= "&" if ("$str" ne "");
	$str .= "a8=$a8";
    }
    return $str;
}


# create alliance selection table
print "<table cellpadding=5 cellspacing=5 border=1><tr>\n";

my $alliance = 1;
my $end = "";
my $ptr = "&nbsp;";
if ($pos < 3 || $pos == 24 || $pos == 25) {
    $ptr = "->";
    my $alink = makealink(1);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a1=$a1";
    $end .= "-" if ("$a1" ne "");
}
my $tlink = "&nbsp;";
$tlink = $a1 if ("$a1" ne "");
print "<th>$ptr</th><th>Alliance 1:</th><td>$tlink</td></tr>\n";
$ptr = "&nbsp;";
if ($pos == 3 || $pos == 4 || $pos == 23 || $pos == 26) {
    $ptr = "->";
    $alliance = 2;
    my $alink = makealink(2);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a2=$a2";
    $end .= "-" if ("$a2" ne "");
}
$tlink = "&nbsp;";
$tlink = $a2 if ("$a2" ne "");
print "<tr><th>$ptr</th><th>Alliance 2:</th><td>$tlink</td></tr>\n";
$ptr = "&nbsp;";
if ($pos == 5 || $pos == 6 || $pos == 22 || $pos == 27) {
    $ptr = "->";
    $alliance = 3;
    my $alink = makealink(3);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a3=$a3";
    $end .= "-" if ("$a3" ne "");
}
$tlink = "&nbsp;";
$tlink = $a3 if ("$a3" ne "");
print "<tr><th>$ptr</th><th>Alliance 3:</th><td>$tlink</td></tr>\n";
$ptr = "&nbsp;";
if ($pos == 7 || $pos == 8 || $pos == 21 || $pos == 28) {
    $ptr = "->";
    $alliance = 4;
    my $alink = makealink(4);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a4=$a4";
    $end .= "-" if ("$a4" ne "");
}
$tlink = "&nbsp;";
$tlink = $a4 if ("$a4" ne "");
print "<tr><th>$ptr</th><th>Alliance 4:</th><td>$tlink</td></tr>\n";
$ptr = "&nbsp;";
if ($pos == 9 || $pos == 10 || $pos == 20 || $pos == 29) {
    $ptr = "->";
    $alliance = 5;
    my $alink = makealink(5);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a5=$a5";
    $end .= "-" if ("$a5" ne "");
}
$tlink = "&nbsp;";
$tlink = $a5 if ("$a5" ne "");
print "<tr><th>$ptr</th><th>Alliance 5:</th><td>$tlink</td></tr>\n";
$ptr = "&nbsp;";
if ($pos == 11 || $pos == 12 || $pos == 19 || $pos == 30) {
    $ptr = "->";
    $alliance = 6;
    my $alink = makealink(6);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a6=$a6";
    $end .= "-" if ("$a6" ne "");
}
$tlink = "&nbsp;";
$tlink = $a6 if ("$a6" ne "");
print "<tr><th>$ptr</th><th>Alliance 6:</th><td>$tlink</td></tr>\n";
$ptr = "&nbsp;";
if ($pos == 13 || $pos == 14 || $pos == 18 || $pos == 31) {
    $ptr = "->";
    $alliance = 7;
    my $alink = makealink(7);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a7=$a7";
    $end .= "-" if ("$a7" ne "");
}
$tlink = "&nbsp;";
$tlink = $a7 if ("$a7" ne "");
print "<tr><th>$ptr</th><th>Alliance 7:</th><td>$tlink</td></tr>\n";
$ptr = "&nbsp;";
if ($pos == 15 || $pos == 16 || $pos == 17 || $pos == 32) {
    $ptr = "->";
    $alliance = 8;
    my $alink = makealink(8);
    $link .= "&" . $alink if ("$alink" ne "");
    $end = "a8=$a8";
    $end .= "-" if ("$a8" ne "");
}
$tlink = "&nbsp;";
$tlink = $a8 if ("$a8" ne "");
print "<tr><th>$ptr</th><th>Alliance 8:</th><td>$tlink</td></tr>\n";
print "</tr></table>\n";

my $alla = "";
$alla = "a1=$a1" if ("$a1" ne "");
if ("$a2" ne "") {
    $alla .= "&" if ("$alla" ne "");
    $alla .= "a2=$a2";
}
if ("$a3" ne "") {
    $alla .= "&" if ("$alla" ne "");
    $alla .= "a3=$a3";
}
if ("$a4" ne "") {
    $alla .= "&" if ("$alla" ne "");
    $alla .= "a4=$a4";
}
if ("$a5" ne "") {
    $alla .= "&" if ("$alla" ne "");
    $alla .= "a5=$a5";
}
if ("$a6" ne "") {
    $alla .= "&" if ("$alla" ne "");
    $alla .= "a6=$a6";
}
if ("$a7" ne "") {
    $alla .= "&" if ("$alla" ne "");
    $alla .= "a7=$a7";
}
if ("$a8" ne "") {
    $alla .= "&" if ("$alla" ne "");
    $alla .= "a8=$a8";
}

print "<H3>";
if (@aa1 > 2) {
    print "<a href=\"${me}?event=${event}&pos=${npos}&${alla}&save=yes\">Save Alliances</a>";
    print " or " if ($end ne "");
}
print "Select for Alliance ${alliance}:" if ($end ne "");
print "</H3>\n";

if ($end ne "") {
    my @teams = sort(keys %teamlist);
    print "<table cellpadding=5 cellspacing=5 border=1><tr>\n";
    my $count = 0;
    foreach my $t (@teams) {
	my $found = 0;
	foreach my $c (@aa1, @aa2, @aa3, @aa4, @aa5, @aa6, @aa7, @aa8) {
	    if ($c eq $t) {
		$found = 1;
		last;
	    }
	}
	next if ($found != 0);
	print "<td><a href=\"${link}&${end}$t\">$t</a></td>\n";
	$count++;
	print "</tr><tr>\n" if ($count % 10 == 0);
    }
    while ($count % 10 != 0) {
	$count++;
	print "<td>&nbsp;</td>\n";
    }
    print "</tr></table>\n";
}
print "</body></html>\n";
