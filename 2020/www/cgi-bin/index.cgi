#!/usr/bin/perl -w

use strict;
use warnings;

my $me = "index.cgi";
my $picdir = "/scoutpics";

my $event = "";
my $pos = "";
my $orient = "right";

if (exists $ENV{QUERY_STRING}) {
	my @args = split /\&/, $ENV{QUERY_STRING};
	my %params;
	foreach my $arg (@args) {
		my @bits = split /=/, $arg;
		next unless (@bits == 2);
		$params{$bits[0]} = $bits[1];
	}
	$event  = $params{'event'} if (defined $params{'event'});
	$pos    = $params{'pos'} if (defined $params{'pos'});
	$orient = $params{'orient'} if (defined $params{'orient'});
}

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body><center>\n";
print "<H1>FRC 1073 Scouting App</H1>\n";

my @argCheck = split /\s+/, $event;
if (@argCheck > 1) {
    print "<p>ARG ERROR</p>\n";
    print "</body></html>\n";
    exit 0;
}

my $events = `ls -1 matchdata/*.dat`;
my @files = split /\n/, $events;

if (@files < 1) {
	print "<p>There are no event files found.</p>\n";
	print "</body></html>\n";
	exit 0;
}

if ( "$event" ne "") {
    my $eventCheck = "matchdata/${event}.dat";
    my $found = 0;
    foreach my $f (@files) {
	if ("$eventCheck" eq "$f") {
	    $found = 1;
	    last;
	}
    }
    if ($found == 0) {
	print "<p>Error, invalid event</p>\n";
	print "</body></html>\n";
	exit 0;
    }
}


if ("$event" eq "") {
    print "<H3><A href=\"/index.html\">Back to 'Start'</a></H3>\n";
    print "<table cellspacing=5 cellpadding=5 border=0>\n";
	foreach my $f (@files) {
	    my @fname = split /\//, $f;
	    my @name = split /\./, $fname[-1];
	    print "<tr><td><h2><a href=\"${me}?event=$name[0]\">$name[0]</a></h2></td>";
	    print "<td>";
	    if ( -f "/var/www/cgi-bin/matchdata/$name[0].elims" ) {
		print "<h2><a href=\"elims.cgi?event=$name[0]\">Alliances</a></h2>\n";
	    } else {
		print "&nbsp;";
	    }
	    print "</td>\n";
	    my $csvfile = "/csv/" . $name[0] . ".txt";
	    if ( -f "/var/www/html/$csvfile" ) {
		print "<td><h2><a href=\"opr.cgi?event=$name[0]\">Analysis</a></h2>\n";
		print "</td><td>&nbsp;&nbsp;</td>";
		print "<td><h2><a href=\"matchup.cgi?event=$name[0]\">Prediction</a></h2>\n";
		print "</td><td>&nbsp;&nbsp;</td>";
		print "<td><h2>(<a href=\"$csvfile\">CSV file</a>)</h2></td>";
	    } else {
		print "<td>&nbsp;</td><td>&nbsp;&nbsp;</td><td>&nbsp;</td><td>&nbsp;&nbsp;</td><td>&nbsp;</td>";
		print "<td>&nbsp;</td>";
	    }
	    print "</tr>\n";
	}
    print "</table>\n";
} else {
    if ("$pos" eq "") {
	print "<H2>Pick your Field View and Robot Position</H2>\n";
	print "<table cellpadding=20 cellspacing=10><tr>\n";
	my $RED  = "bgcolor=\"#ff6666\"";
	my $BLUE = "bgcolor=\"#99ccff\"";
	print "<td $RED><h1><a href=\"${me}?event=${event}&pos=R1&orient=left\">R1</a>&nbsp;&nbsp;</h1></td>\n";
	print "<td rowspan=3><img src=$picdir/full_field_blue_robots.png></td>\n";
	print "<td $BLUE><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B1&orient=right\">B1</a></h1></td>\n";
	print "</tr><tr>\n";
	print "<td $RED><H1><a href=\"${me}?event=${event}&pos=R2&orient=left\">R2</a>&nbsp;&nbsp;</h1></td>\n";
	print "<td $BLUE><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B2&orient=right\">B2</a></h1></td>\n";
	print "</tr><tr>\n";
	print "<td $RED><H1><a href=\"${me}?event=${event}&pos=R3&orient=left\">R3</a>&nbsp;&nbsp;</h1></td>\n";
	print "<td $BLUE><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B3&orient=right\">B3</a></h1></td>\n";
	print "</tr></table>\n";
	print "<H1>OR</H1>\n";
	print "<table cellpadding=20 cellspacing=10><tr>\n";
	print "<td $BLUE><H1><a href=\"${me}?event=${event}&pos=B1&orient=left\">B1</a>&nbsp;&nbsp;</h1></td>\n";
	print "<td rowspan=3><img src=$picdir/full_field_red_robots.png></td>\n";
	print "<td $RED><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R1&orient=right\">R1</a></h1></td>\n";
	print "</tr><tr>\n";
	print "<td $BLUE><H1><a href=\"${me}?event=${event}&pos=B2&orient=left\">B2</a>&nbsp;&nbsp;</h1></td>\n";
	print "<td $RED><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R2&orient=right\">R2</a></h1></td>\n";
	print "</tr><tr>\n";
	print "<td $BLUE><H1><a href=\"${me}?event=${event}&pos=B3&orient=left\">B3</a>&nbsp;&nbsp;</h1></td>\n";
	print "<td $RED><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R3&orient=right\">R3</a></h1></td>\n";
	print "</tr></table>\n";
    } else {
	# list matches for this position
	my $file = $event . ".dat";
	my $data = `cat matchdata/${file}`;
	my @lines = split /\n/, $data;
	my %mhash;
	my $count = 0;
	foreach my $line (@lines) {
	    my @items = split /=/, $line;
	    next unless (@items > 1);
	    my $k = $items[0];
	    my $v = $items[1];
	    $k =~ s/^\s+|\s+$//g;
	    $v =~ s/^\s+|\s+$//g;
	    $mhash{$k} = $v;
	    my @bits = split '_', $k;
	    next unless (@bits > 1);
	    $count = substr $bits[1], 2;
	}
	# any elims?
	my %alliances;
	if ( -f "/var/www/cgi-bin/matchdata/$event.elims" ) {
	    $data = `cat /var/www/cgi-bin/matchdata/$event.elims`;
	    @lines = split /\n/, $data;
	    my $i = 1;
	    foreach my $line (@lines) {
		$alliances{$i} = $line;
		$i++;
	    }
	}
	my @all = keys %alliances;

	print "<p style=\"font-size:25px; font-weight:bold;\"><a href=\"index.cgi\">Home</a></p>\n";

	if (@all > 0) {
	    # include elims
	    print "<table cellpadding=0 cellspacing=0 border=0><tr><td>\n";
	}
	
	my @bits = split "", $pos;
	my $num = int $bits[1];
	$num += 3 if ($bits[0] eq "B");
	print "<table border=1 cellspacing=5 cellpadding=5>\n";
	print "<tr><th colspan=2><p style=\"font-size:25px; font-weight:bold;\">$event $pos</p></th></tr>\n";
	for (my $m = 1; $m <= $count; $m++) {
	    print "<tr><td><p style=\"font-size:20px; font-weight:bold;\">Qual $m</p></td>\n";
	    my $key = $event . "_qm" . $m . "_" . $num;
	    if (defined $mhash{$key}) {
		my $sfile = "blue_${orient}.cgi";
		if ($num < 4) {
		    $sfile = "red_${orient}.cgi";
		}
		print "<td><p style=\"font-size:20px; font-weight:bold;\">";
		print "<a href=\"${sfile}?game=${key}&team=$mhash{$key}\">";
		print "$pos : $mhash{$key}</a></p></td>\n";
	    } else {
		print "<td><p style=\"font-size:20px; font-weight:bold;\">&nbsp;$key</p></td>\n";
	    }
	    print "</tr>\n";
	}
	print "</table>\n";

	if (@all > 0) {
	    # include elims
	    print "</td><td>&nbsp; &nbsp; &nbsp;</td><td>&nbsp; &nbsp; &nbsp;</td><td valign=top>\n";
	    print "<table cellpadding=5 cellspacing=5 border=1>";
	    print "<tr><th colspan=2><p style=\"font-size:25px; font-weight:bold;\">QF $pos</p></th></tr>\n";
	    # set text size for table
	    my $pstyle = "<p style=\"font-size:20px; font-weight:bold;\">";
	    if ($num < 4) {
		# RED takes alliances 1-4
		my $sfile = "red_${orient}.cgi";
		my @a1 = split /-/, $alliances{"1"};
		my @a2 = split /-/, $alliances{"2"};
		my @a3 = split /-/, $alliances{"3"};
		my @a4 = split /-/, $alliances{"4"};
		print "<tr><th>${pstyle}QF 1</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf1_$num&team=$a1[$num-1]\">";
		print "$pos : $a1[$num-1]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 2</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf2_$num&team=$a4[$num-1]\">";
		print "$pos : $a4[$num-1]</a></p></td>\n";
		
		print "<tr><th>${pstyle}QF 3</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf3_$num&team=$a2[$num-1]\">";
		print "$pos : $a2[$num-1]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 4</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf4_$num&team=$a3[$num-1]\">";
		print "$pos : $a3[$num-1]</a></p></td>\n";

		print "<tr><td colspan=2>&nbsp;</td></tr>\n";
		print "<tr><th>${pstyle}QF 5</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf5_$num&team=$a1[$num-1]\">";
		print "$pos : $a1[$num-1]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 6</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf6_$num&team=$a4[$num-1]\">";
		print "$pos : $a4[$num-1]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 7</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf7_$num&team=$a2[$num-1]\">";
		print "$pos : $a2[$num-1]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 8</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf8_$num&team=$a3[$num-1]\">";
		print "$pos : $a3[$num-1]</a></p></td>\n";

		print "<tr><td colspan=2 align=center>(tiebreakers)</td></tr>\n";
		print "<tr><th>${pstyle}QF 9</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf9_$num&team=$a1[$num-1]\">";
		print "$pos : $a1[$num-1]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 10</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf10_$num&team=$a4[$num-1]\">";
		print "$pos : $a4[$num-1]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 11</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf11_$num&team=$a2[$num-1]\">";
		print "$pos : $a2[$num-1]</a></p></td>\n";

		print "<tr><td>${pstyle}QF 12</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf12_$num&team=$a3[$num-1]\">";
		print "$pos : $a3[$num-1]</a></p></td>\n";
	    } else {
		# BLUE takes alliances 5-8
		my $sfile = "blue_${orient}.cgi";
		my @a5 = split /-/, $alliances{"5"};
		my @a6 = split /-/, $alliances{"6"};
		my @a7 = split /-/, $alliances{"7"};
		my @a8 = split /-/, $alliances{"8"};
		print "<tr><th>${pstyle}QF 1</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf1_$num&team=$a8[$num-4]\">";
		print "$pos : $a8[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 2</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf2_$num&team=$a5[$num-4]\">";
		print "$pos : $a5[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 3</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf3_$num&team=$a7[$num-4]\">";
		print "$pos : $a7[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 4</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf4_$num&team=$a6[$num-4]\">";
		print "$pos : $a6[$num-4]</a></p></td>\n";

		print "<tr><td colspan=2>&nbsp;</td></tr>\n";
		print "<tr><th>${pstyle}QF 5</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf5_$num&team=$a8[$num-4]\">";
		print "$pos : $a8[$num-4]</a></p></td>\n";
		
		print "<tr><th>${pstyle}QF 6</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf6_$num&team=$a5[$num-4]\">";
		print "$pos : $a5[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 7</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf7_$num&team=$a7[$num-4]\">";
		print "$pos : $a7[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 8</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf8_$num&team=$a6[$num-4]\">";
		print "$pos : $a6[$num-4]</a></p></td>\n";

		print "<tr><td colspan=2 align=center>(tiebreakers)</td></tr>\n";
		print "<tr><th>${pstyle}QF 9</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf9_$num&team=$a8[$num-4]\">";
		print "$pos : $a8[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 10</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf10_$num&team=$a5[$num-4]\">";
		print "$pos : $a5[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 11</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf11_$num&team=$a7[$num-4]\">";
		print "$pos : $a7[$num-4]</a></p></td>\n";

		print "<tr><th>${pstyle}QF 12</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_qf12_$num&team=$a6[$num-4]\">";
		print "$pos : $a6[$num-4]</a></p></td>\n";
	    }
	    print "</table>\n";
	    print "<BR><BR>\n";
	    # are semifinals configured?
	    my $semif = "/var/www/cgi-bin/matchdata/${event}.semis";
	    if (-f "$semif" ) {
		my @semit;
		if (open my $fh, "<", $semif) {
		    while (my $line = <$fh>) {
			chomp $line;
			push @semit, $line;
		    }
		    close $fh;
		} else {
		    print "<H2>Error opening $semif: $!</H2>\n";
		    print "</td></tr></table>\n";
		    print "</body></html>\n";
		    exit 0;
		}
		print "<table cellpadding=5 cellspacing=5 border=1>\n";
		print "<tr><th colspan=2><p style=\"font-size:25px; font-weight:bold;\">SF $pos</p></th></tr>\n";
		# set text size for table
		my $pstyle = "<p style=\"font-size:20px; font-weight:bold;\">";
		# set defaults to red alliance
		my $sfile = "red_${orient}.cgi";
		my $index = $num - 1;
		my @s1;
		my @s2;
		if ($num < 4) {
		    # RED takes alliances 1(0),2(2)
		    @s1 = split /-/, $semit[0];
		    @s2 = split /-/, $semit[2];
		} else {
		    # BLUE takes alliances 3(1),4(3)
		    $sfile = "blue_${orient}.cgi";
		    @s1 = split /-/, $semit[1];
		    @s2 = split /-/, $semit[3];
		    $index = $num - 4;
		}
		print "<tr><th>${pstyle}SF 1</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_sf1_$num&team=$s1[$index]\">";
		print "$pos : $s1[$index]</a></p></td>\n";

		print "<tr><th>${pstyle}SF 2</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_sf2_$num&team=$s2[$index]\">";
		print "$pos : $s2[$index]</a></p></td>\n";

		print "<tr><td colspan=2>&nbsp;</td></tr>\n";

		print "<tr><th>${pstyle}SF 3</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_sf3_$num&team=$s1[$index]\">";
		print "$pos : $s1[$index]</a></p></td>\n";

		print "<tr><th>${pstyle}SF 4</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_sf4_$num&team=$s2[$index]\">";
		print "$pos : $s2[$index]</a></p></td>\n";

		print "<tr><td colspan=2 align=center><p>(tiebreakers)</p></td></tr>\n";
		
		print "<tr><th>${pstyle}SF 5</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_sf5_$num&team=$s1[$index]\">";
		print "$pos : $s1[$index]</a></p></td>\n";

		print "<tr><th>${pstyle}SF 6</p></th>";
		print "<td>${pstyle}<a href=\"${sfile}?game=${event}_sf6_$num&team=$s2[$index]\">";
		print "$pos : $s2[$index]</a></p></td>\n";

		print "</table>\n";
	    }
	    print "</td></tr></table>\n";
	}
    }
}
print "</body></html>\n";
