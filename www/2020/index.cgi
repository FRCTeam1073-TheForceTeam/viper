#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use lib '../../pm';
use webutil;

my $cgi = CGI->new;
my $webutil = webutil->new;
my $me = "index.cgi";

my $event = $cgi->param('event')||"";
$webutil->error("Bad event parameter", $event) if ($event && $event !~ /^2020[0-9a-zA-Z_\-]+$/);
my $pos = $cgi->param('pos');
$webutil->error("Bad pos parameter", $pos) if ($pos && $pos !~ /^[RB][1-3]$/);
my $orient = $cgi->param('orient') || "right";
$webutil->error("Bad orient parameter", $orient) if ($orient !~ /^(left|right)$/);

# print web page beginning
print "Content-type: text/html; charset=UTF-8\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Scouting App</title>\n";
print "</head>\n";
print "<body><center>\n";
print "<h1>FRC 1073 Scouting App</h1>\n";

my $events = `ls -1 ../data/2020*.schedule.csv`;
my @files = split /\n/, $events;

if (@files < 1) {
	print "<p>There are no event files found.</p>\n";
	print "</body></html>\n";
	exit 0;
}

if ( "$event" ne "") {
	 my $eventCheck = "../data/${event}.schedule.csv";
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
	 print "<h3><a href=\"/\">Back to 'Start'</a></h3>\n";
	 print "<table cellspacing=5 cellpadding=5 border=0>\n";
	foreach my $f (@files) {
		my @fname = split /\//, $f;
		my @name = split /\./, $fname[-1];
		print "<tr><td><h2><a href=\"${me}?event=$name[0]\">$name[0]</a></h2></td>";
		print "<td>";
		if ( -f "../data/$name[0].alliances.csv" ) {
			print "<h2><a href=\"elims.cgi?event=$name[0]\">Alliances</a></h2>\n";
		} else {
			print "&nbsp;";
		}
		print "</td>\n";
		my $csvfile = "/../data/" . $name[0] . ".scouting.csv";
		if ( -f "$csvfile" ) {
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
		  print "<h2>Pick your Field View and Robot Position</h2>\n";
		  print "<table cellpadding=20 cellspacing=10><tr>\n";
		  my $RED  = "bgcolor=\"#ff6666\"";
		  my $BLUE = "bgcolor=\"#99ccff\"";
		  print "<td $RED><h1><a href=\"${me}?event=${event}&pos=R1&orient=left\">R1</a>&nbsp;&nbsp;</h1></td>\n";
		  print "<td rowspan=3><img src=full_field_blue_robots.png></td>\n";
		  print "<td $BLUE><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B1&orient=right\">B1</a></h1></td>\n";
		  print "</tr><tr>\n";
		  print "<td $RED><h1><a href=\"${me}?event=${event}&pos=R2&orient=left\">R2</a>&nbsp;&nbsp;</h1></td>\n";
		  print "<td $BLUE><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B2&orient=right\">B2</a></h1></td>\n";
		  print "</tr><tr>\n";
		  print "<td $RED><h1><a href=\"${me}?event=${event}&pos=R3&orient=left\">R3</a>&nbsp;&nbsp;</h1></td>\n";
		  print "<td $BLUE><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B3&orient=right\">B3</a></h1></td>\n";
		  print "</tr></table>\n";
		  print "<h1>OR</h1>\n";
		  print "<table cellpadding=20 cellspacing=10><tr>\n";
		  print "<td $BLUE><h1><a href=\"${me}?event=${event}&pos=B1&orient=left\">B1</a>&nbsp;&nbsp;</h1></td>\n";
		  print "<td rowspan=3><img src=full_field_red_robots.png></td>\n";
		  print "<td $RED><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R1&orient=right\">R1</a></h1></td>\n";
		  print "</tr><tr>\n";
		  print "<td $BLUE><h1><a href=\"${me}?event=${event}&pos=B2&orient=left\">B2</a>&nbsp;&nbsp;</h1></td>\n";
		  print "<td $RED><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R2&orient=right\">R2</a></h1></td>\n";
		  print "</tr><tr>\n";
		  print "<td $BLUE><h1><a href=\"${me}?event=${event}&pos=B3&orient=left\">B3</a>&nbsp;&nbsp;</h1></td>\n";
		  print "<td $RED><h1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R3&orient=right\">R3</a></h1></td>\n";
		  print "</tr></table>\n";
	 } else {
		  # list matches for this position
		  my $file = $event . ".schedule.csv";
		  my $data = `cat ../data/${file}`;
		my $matches = [ split /\n/, $data ];
		foreach my $i (0..(scalar(@$matches)-1)) {
			$matches->[$i] = [ split(/,/, $matches->[$i]) ];
		}

		  print "<p style=\"font-size:25px; font-weight:bold;\"><a href=\"index.cgi\">Home</a></p>\n";

		my $posMap = {
			"R1"=>1,
			"R2"=>2,
			"R3"=>3,
			"B1"=>4,
			"B2"=>5,
			"B3"=>6,
		};

		  my @bits = split "", $pos;
		  my $num = int $bits[1];
		  $num += 3 if ($bits[0] eq "B");
		  print "<table border=1 cellspacing=5 cellpadding=5>\n";
		  print "<tr><th colspan=2><p style=\"font-size:25px; font-weight:bold;\">$event $pos</p></th></tr>\n";
		foreach my $i (0..(scalar(@$matches)-1)) {
			print "<tr><td><p style=\"font-size:20px; font-weight:bold;\">".$matches->[$i]->[$0]."</p></td>\n";
			my $key = $event . "_" . $matches->[$i]->[$0] . "_" . $pos;
			my $team = $matches->[$i]->[$posMap->{$pos}];
				my $color = ($pos=~/^R/)?"red":"blue";
			print "<td><p style=\"font-size:20px; font-weight:bold;\"><a href=\"${color}_${orient}.cgi?game=${key}&team=${team}\">$pos : ${team}</a></p></td>\n";
			print "</tr>\n";
		}
		  print "</table>\n";
	 }
}
print "</body></html>\n";
