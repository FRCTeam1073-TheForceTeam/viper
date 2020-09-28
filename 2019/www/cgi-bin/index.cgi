#!/usr/bin/perl -w

use strict;
use warnings;

my $me = "index.cgi";

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

if ("$event" eq "") {
    print "<table cellspacing=5 cellpadding=5 border=0>\n";
	foreach my $f (@files) {
	    my @fname = split /\//, $f;
	    my @name = split /\./, $fname[-1];
	    print "<tr><td><h2><a href=\"${me}?event=$name[0]\">$name[0]</a></h2></td>";
	    print "<td>&nbsp;&nbsp;</td>";
	    my $csvfile = "/csv/" . $name[0] . ".txt";
	    if ( -f "/var/www/html/$csvfile" ) {
		print "<td><h2><a href=\"opr.cgi?event=$name[0]\">Match Data</a></h2>\n";
		print "</td><td>&nbsp;&nbsp;</td>";
		print "<td><h2><a href=\"matchup.cgi?event=$name[0]\">Match Predictor</a></h2>\n";
		print "</td><td>&nbsp;&nbsp;</td><td><h2>(";
		print "<a href=\"$csvfile\">CSV file</a>)</h2></td>";
	    } else {
		print "<td>&nbsp;</td><td>&nbsp;&nbsp;</td><td>&nbsp;</td><td>&nbsp;&nbsp;</td><td>&nbsp;</td>";
	    }
	    print "</tr>\n";
	}
    print "</table>\n";
} else {
	if ("$pos" eq "") {
		print "<table cellpadding=20 cellspacing=10><tr>\n";
		print "<td bgcolor=\"#ff6666\"><h1><a href=\"${me}?event=${event}&pos=R1&orient=left\">R1</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td bgcolor=\"#99ccff\"><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B1&orient=right\">B1</a></h1></td>\n";
		print "<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>\n";
		print "<td bgcolor=\"#99ccff\"><H1><a href=\"${me}?event=${event}&pos=B1&orient=left\">B1</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td bgcolor=\"#ff6666\"><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R1&orient=right\">R1</a></h1></td>\n";
		print "</tr><tr>\n";
		print "<td bgcolor=\"#ff6666\"><H1><a href=\"${me}?event=${event}&pos=R2&orient=left\">R2</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td bgcolor=\"#99ccff\"><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B2&orient=right\">B2</a></h1></td>\n";
		print "<td><h1>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OR&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</H1></td>\n";
		print "<td bgcolor=\"#99ccff\"><H1><a href=\"${me}?event=${event}&pos=B2&orient=left\">B2</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td bgcolor=\"#ff6666\"><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R2&orient=right\">R2</a></h1></td>\n";
		print "</tr><tr>\n";
		print "<td bgcolor=\"#ff6666\"><H1><a href=\"${me}?event=${event}&pos=R3&orient=left\">R3</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td bgcolor=\"#99ccff\"><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=B3&orient=right\">B3</a></h1></td>\n";
		print "<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>\n";
		print "<td bgcolor=\"#99ccff\"><H1><a href=\"${me}?event=${event}&pos=B3&orient=left\">B3</a>&nbsp;&nbsp;</h1></td>\n";
		print "<td bgcolor=\"#ff6666\"><H1>&nbsp;&nbsp;<a href=\"${me}?event=${event}&pos=R3&orient=right\">R3</a></h1></td>\n";
		print "</tr></table>\n";
		print "<br><h2>Pick your field orientation and robot position</<h2>\n";
	} else {
		my $file = $event . ".dat";
		my $data = `cat matchdata/${file}`;
		my @lines = split /\n/, $data;
		my %mhash;
		foreach my $line (@lines) {
			my @items = split /=/, $line;
			next unless (@items > 1);
			my $k = $items[0];
			my $v = $items[1];
			$k =~ s/^\s+|\s+$//g;
			$v =~ s/^\s+|\s+$//g;
			$mhash{$k} = $v;
		}
		my $count = keys %mhash;

		print "<p style=\"font-size:25px; font-weight:bold;\"><a href=\"index.cgi\">Home</a></p>\n";

		my @bits = split "", $pos;
		my $num = $bits[1];
		$num += 3 if ($bits[0] eq "B");
		print "<table border=1 cellspacing=5 cellpadding=5>\n";
		print "<tr><th colspan=2><p style=\"font-size:25px; font-weight:bold;\">$event $pos</p></th></tr>\n";
		for (my $m = 1; $m < $count; $m++) {
			print "<tr><td><p style=\"font-size:20px; font-weight:bold;\">Qual $m</p></td>\n";
			my $key = $event . "_qm" . $m . "_" . $num;
			if (defined $mhash{$key}) {
				print "<td><p style=\"font-size:20px; font-weight:bold;\"><a href=\"${orient}.cgi?game=${key}&team=$mhash{$key}\">$pos : $mhash{$key}</a></p></td>\n";
			} else {
				print "<td><p style=\"font-size:20px; font-weight:bold;\">&nbsp;$key</p></td>\n";
			}
			print "</tr>\n";
		}
	}
}
print "</body></html>\n";
