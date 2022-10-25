#!/usr/bin/perl -w

#
# This script displays three HTML pages:
# - the page displaying the list of events
# - the page displaying the field selection and drive team positions
# - the page that displays all of the matches for the given drive team position
#
# The choice of which page to display depends on which arguments are given:
# - if no event, the display the events page
# - if event but no position, then display the field selection and drive team position page
# - if event and position, then display the list of matches for this drive team position at this event
#

use strict;
use warnings;

my $me = "index.cgi";
my $picdir = "/2022/scoutpics";
my $scout = "react.cgi";

my $event = "";
my $pos = "";

if (exists $ENV{QUERY_STRING}) {
	my @args = split /\&/, $ENV{QUERY_STRING};
	my %params;
	foreach my $arg (@args) {
		my @bits = split /=/, $arg;
		next unless (@bits == 2);
		$params{$bits[0]} = $bits[1];
	}
	# set these parameters if they were given AND have a valid value
	$event  = $params{'event'}  if (exists $params{'event'}  && defined $params{'event'});
	$pos    = $params{'pos'}    if (exists $params{'pos'}    && defined $params{'pos'});
}

# print web page beginning
print "Content-type: text/html; charset=UTF-8\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC Scouting App</title>\n";
print "</head>\n";
print "<body><center>\n";
print "<h1>FRC Scouting App</h1>\n";

# if event is given, make sure that 'event' does not contain any spaces
if ("$event" ne "") {
    my @argCheck = split /\s+/, $event;
    if (@argCheck > 1) {
		print "<p>ARG ERROR</p>\n";
		print "</body></html>\n";
		exit 0;
    }
}

# get all of the event files containing match schedules
my $events = `ls -1 -r ../data/*.quals.csv`;
my @files = split /\n/, $events;

if (@files < 1) {
	print "<p>There are no event files found.</p>\n";
	print "</body></html>\n";
	exit 0;
}

if ( "$event" ne "") {
    my $eventCheck = "../data/${event}.quals.csv";
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
    print "<table cellspacing=5 cellpadding=5 border=0>\n";
	foreach my $f (@files) {
	    my @fname = split /\//, $f;
	    my @name = split /\./, $fname[-1];
	    print "<tr><td><h2><a href=\"${me}?event=$name[0]\">$name[0]</a></h2></td>";
	    print "<td>";
	    if ( -f "../data/$name[0].elims" ) {
			print "<h2><a href=\"elims.cgi?event=$name[0]\">Alliances</a></h2>\n";
	    } else {
			print "&nbsp;";
	    }
	    print "</td>\n";
	    my $csvfile = "../data/" . $name[0] . ".txt";
	    if ( -f "$csvfile" ) {
			print "<td><h2><a href=\"opr.cgi?event=$name[0]\">Analysis</a></h2>\n";
			print "</td><td>&nbsp;&nbsp;</td>";
			print "<td><h2><a href=\"matchup.cgi?event=$name[0]\">Prediction</a></h2>\n";
			print "</td><td>&nbsp;&nbsp;</td>";
			print "<td><h2>(<a href=\"$csvfile\">CSV file</a>)</h2></td>";
	    } else {
			print "<td>&nbsp;</td><td>&nbsp;&nbsp;</td><td>&nbsp;</td><td>&nbsp;&nbsp;</td><td>&nbsp;</td>";
			print "<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
	    }
	    	print "</tr>\n";
	}
    print "</table>\n";
} else {
    if ("$pos" eq "") {
		print "<h2>Select your robot</h2>\n";
		print "<table cellpadding=20 cellspacing=10><tr>\n";
		my $RED  = "bgcolor=\"#ff6666\"";
		my $BLUE = "bgcolor=\"#99ccff\"";
		print "<td $BLUE><h1><a href=\"${me}?event=${event}&pos=B1\">B1</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td rowspan=3><img src=$picdir/field.png></td>\n";
		print "<td $RED><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R1\">R1</a></h1></td>\n";
		print "</tr><tr>\n";
		print "<td $BLUE><h1><a href=\"${me}?event=${event}&pos=B2\">B2</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td $RED><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R2\">R2</a></h1></td>\n";
		print "</tr><tr>\n";
		print "<td $BLUE><h1><a href=\"${me}?event=${event}&pos=B3\">B3</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td $RED><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R3\">R3</a></h1></td>\n";
		print "</tr></table>\n";
		print "<img src=\"$picdir/hub.png\">\n";
		print "<img src=\"$picdir/hangar.png\">\n";
    } else {
		# list matches for this position
		my $file = $event . ".quals.csv";
		my $data = `cat ../data/${file}`;
		my $quals = [ split /\n/, $data ];
		foreach my $i (0..(scalar(@$quals)-1)) {
			$quals->[$i] = [ split(/,/, $quals->[$i]) ];
		}
		print STDERR $quals;
		# any elims?
		my %alliances;
		if ( -f "../data/$event.elims" ) {
			$data = `cat data/$event.elims`;
			my $i = 1;
			foreach my $line (split /\n/, $data) {
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
		for (my $m = 1; $m <= scalar(@$quals)-1; $m++) {
			print "<tr><td><p style=\"font-size:20px; font-weight:bold;\">Qual $m</p></td>\n";
			my $key = $event . "_qm" . $m . "_" . $num;
			my $team = $quals->[$m]->[$num];
			print "<td><p style=\"font-size:20px; font-weight:bold;\">";
			print "<a href=\"${scout}?game=${key}&team=$team\">";
			print "$pos : $team</a></p></td>\n";
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
				my @a1 = split /-/, $alliances{"1"};
				my @a2 = split /-/, $alliances{"2"};
				my @a3 = split /-/, $alliances{"3"};
				my @a4 = split /-/, $alliances{"4"};
				print "<tr><th>${pstyle}QF 1</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf1_$num&team=$a1[$num-1]\">";
				print "$pos : $a1[$num-1]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 2</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf2_$num&team=$a4[$num-1]\">";
				print "$pos : $a4[$num-1]</a></p></td>\n";
				
				print "<tr><th>${pstyle}QF 3</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf3_$num&team=$a2[$num-1]\">";
				print "$pos : $a2[$num-1]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 4</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf4_$num&team=$a3[$num-1]\">";
				print "$pos : $a3[$num-1]</a></p></td>\n";

				print "<tr><td colspan=2>&nbsp;</td></tr>\n";
				print "<tr><th>${pstyle}QF 5</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf5_$num&team=$a1[$num-1]\">";
				print "$pos : $a1[$num-1]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 6</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf6_$num&team=$a4[$num-1]\">";
				print "$pos : $a4[$num-1]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 7</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf7_$num&team=$a2[$num-1]\">";
				print "$pos : $a2[$num-1]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 8</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf8_$num&team=$a3[$num-1]\">";
				print "$pos : $a3[$num-1]</a></p></td>\n";

				print "<tr><td colspan=2 align=center>(tiebreakers)</td></tr>\n";
				print "<tr><th>${pstyle}QF 9</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf9_$num&team=$a1[$num-1]\">";
				print "$pos : $a1[$num-1]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 10</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf10_$num&team=$a4[$num-1]\">";
				print "$pos : $a4[$num-1]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 11</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf11_$num&team=$a2[$num-1]\">";
				print "$pos : $a2[$num-1]</a></p></td>\n";

				print "<tr><td>${pstyle}QF 12</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf12_$num&team=$a3[$num-1]\">";
				print "$pos : $a3[$num-1]</a></p></td>\n";
			} else {
				# BLUE takes alliances 5-8
				my @a5 = split /-/, $alliances{"5"};
				my @a6 = split /-/, $alliances{"6"};
				my @a7 = split /-/, $alliances{"7"};
				my @a8 = split /-/, $alliances{"8"};
				print "<tr><th>${pstyle}QF 1</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf1_$num&team=$a8[$num-4]\">";
				print "$pos : $a8[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 2</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf2_$num&team=$a5[$num-4]\">";
				print "$pos : $a5[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 3</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf3_$num&team=$a7[$num-4]\">";
				print "$pos : $a7[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 4</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf4_$num&team=$a6[$num-4]\">";
				print "$pos : $a6[$num-4]</a></p></td>\n";

				print "<tr><td colspan=2>&nbsp;</td></tr>\n";
				print "<tr><th>${pstyle}QF 5</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf5_$num&team=$a8[$num-4]\">";
				print "$pos : $a8[$num-4]</a></p></td>\n";
				
				print "<tr><th>${pstyle}QF 6</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf6_$num&team=$a5[$num-4]\">";
				print "$pos : $a5[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 7</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf7_$num&team=$a7[$num-4]\">";
				print "$pos : $a7[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 8</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf8_$num&team=$a6[$num-4]\">";
				print "$pos : $a6[$num-4]</a></p></td>\n";

				print "<tr><td colspan=2 align=center>(tiebreakers)</td></tr>\n";
				print "<tr><th>${pstyle}QF 9</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf9_$num&team=$a8[$num-4]\">";
				print "$pos : $a8[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 10</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf10_$num&team=$a5[$num-4]\">";
				print "$pos : $a5[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 11</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf11_$num&team=$a7[$num-4]\">";
				print "$pos : $a7[$num-4]</a></p></td>\n";

				print "<tr><th>${pstyle}QF 12</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_qf12_$num&team=$a6[$num-4]\">";
				print "$pos : $a6[$num-4]</a></p></td>\n";
			}
			print "</table>\n";
			print "<br><br>\n";
			# are semifinals configured?
			my $semif = "../data/${event}.semis";
			if (-f "$semif" ) {
				my @semit;
				if (open my $fh, "<", $semif) {
					while (my $line = <$fh>) {
						chomp $line;
						push @semit, $line;
					}
					close $fh;
				} else {
					print "<h2>Error opening $semif: $!</h2>\n";
					print "</td></tr></table>\n";
					print "</body></html>\n";
					exit 0;
				}
				print "<table cellpadding=5 cellspacing=5 border=1>\n";
				print "<tr><th colspan=2><p style=\"font-size:25px; font-weight:bold;\">SF $pos</p></th></tr>\n";
				# set text size for table
				my $pstyle = "<p style=\"font-size:20px; font-weight:bold;\">";
				# set defaults to red alliance
				my $index = $num - 1;
				my @s1;
				my @s2;
				if ($num < 4) {
					# RED takes alliances 1(0),2(2)
					@s1 = split /-/, $semit[0];
					@s2 = split /-/, $semit[2];
				} else {
					# BLUE takes alliances 3(1),4(3)
					@s1 = split /-/, $semit[1];
					@s2 = split /-/, $semit[3];
					$index = $num - 4;
				}
				print "<tr><th>${pstyle}SF 1</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_sf1_$num&team=$s1[$index]\">";
				print "$pos : $s1[$index]</a></p></td>\n";

				print "<tr><th>${pstyle}SF 2</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_sf2_$num&team=$s2[$index]\">";
				print "$pos : $s2[$index]</a></p></td>\n";

				print "<tr><td colspan=2>&nbsp;</td></tr>\n";

				print "<tr><th>${pstyle}SF 3</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_sf3_$num&team=$s1[$index]\">";
				print "$pos : $s1[$index]</a></p></td>\n";

				print "<tr><th>${pstyle}SF 4</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_sf4_$num&team=$s2[$index]\">";
				print "$pos : $s2[$index]</a></p></td>\n";

				print "<tr><td colspan=2 align=center><p>(tiebreakers)</p></td></tr>\n";
				
				print "<tr><th>${pstyle}SF 5</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_sf5_$num&team=$s1[$index]\">";
				print "$pos : $s1[$index]</a></p></td>\n";

				print "<tr><th>${pstyle}SF 6</p></th>";
				print "<td>${pstyle}<a href=\"${scout}?game=${event}_sf6_$num&team=$s2[$index]\">";
				print "$pos : $s2[$index]</a></p></td>\n";

				print "</table>\n";
			}
			print "</td></tr></table>\n";
		}
    }
}
print "</body></html>\n";
