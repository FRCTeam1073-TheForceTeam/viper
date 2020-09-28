#!/usr/bin/perl -w

use strict;
use warnings;

my $event_year = "";
my $event_venue = "";
my %matches;
my $num_matches = 150;

#
# parse input
#
if ($ENV{QUERY_STRING}) {
	my @args = split /\&/, $ENV{QUERY_STRING};
    my %params;
    foreach my $arg (@args) {
        my @bits = split /=/, $arg;
        next unless (@bits == 2);
        $params{$bits[0]} = $bits[1];
    }
    $event_year  = $params{'event_year'}  if (defined $params{'event_year'});
    $event_venue = $params{'event_venue'} if (defined $params{'event_venue'});
	for (my $i = 1; $i <= $num_matches; $i++) {
		my $key = "Q${i}R1";
		if (defined $params{$key}) {
			$matches{$key} = $params{$key};
		}
		$key = "Q${i}R2";
		if (defined $params{$key}) {
			$matches{$key} = $params{$key};
		}
		$key = "Q${i}R3";
		if (defined $params{$key}) {
			$matches{$key} = $params{$key};
		}
		$key = "Q${i}B1";
		if (defined $params{$key}) {
			$matches{$key} = $params{$key};
		}
		$key = "Q${i}B2";
		if (defined $params{$key}) {
			$matches{$key} = $params{$key};
		}
		$key = "Q${i}B3";
		if (defined $params{$key}) {
			$matches{$key} = $params{$key};
		}
	}
}

my @quals = keys %matches;

# print web page beginning
print "Content-type: text/html\n\n";
print "<html>\n";
print "<head>\n";
print "<title>FRC 1073 Configure Event</title>\n";
print "</head>\n";
print "<body><center>\n";
print "<H1>FRC 1073 Configure Event Qual Matches</H1>\n";

if (@quals < 1) {
	print "<FORM ACTION=\"event.cgi\">\n";
	print "<TABLE CELLPADDNG=5 CELLSPACING=5 BORDER=0><tr>\n";
	print "<TH COLSPAN=3 ALIGN=\"right\"><P>Enter Year: <input type=\"text\"  name=\"event_year\" size=5></P></TD>\n";
	print "<TD>&nbsp;</TD>\n";
	print "<TH COLSPAN=3 ALIGN=\"left\"><P>Enter Venue: <input type=\"text\" name=\"event_venue\" size=10></P></TD>\n";
	print "</TR><TR><TD COLSPAN=7><p>(to match a Blue Alliance event, make sure \"YearVenue\" matches the Blue Alliance 'keyword' for this event)</p></TD>\n";
	print "</TR><TR><TD COLSPAN=7 align=\"center\"><input type=\"submit\" value=\"Save Event\"></TD>\n";
	print "</TR><TR><TD COLSPAN=7>&nbsp;</TD>\n";
	
	for (my $i = 1; $i <= $num_matches; $i++) {
		print "</TR><TR>\n";
		print "<TH><H2>Qual $i</H2></TH>\n";
		print "<TD BGCOLOR=RED><P>R1: <input type=\"text\" name=\"Q${i}R1\" size=5></TD>\n";
		print "<TD BGCOLOR=RED><P>R2: <input type=\"text\" name=\"Q${i}R2\" size=5></TD>\n";
		print "<TD BGCOLOR=RED><P>R3: <input type=\"text\" name=\"Q${i}R3\"size=5></TD>\n";
		print "<TD BGCOLOR=BLUE><P>B1: <input type=\"text\" name=\"Q${i}B1\" size=5></TD>\n";
		print "<TD BGCOLOR=BLUE><P>B2: <input type=\"text\" name=\"Q${i}B2\" size=5></TD>\n";
		print "<TD BGCOLOR=BLUE><P>B3: <input type=\"text\" name=\"Q${i}B3\" size=5></TD>\n";
	}
	print "</tr></table>\n";
} else {
#	my %teamhash;
#	my $max = 1;
#	foreach my $q (keys %matches) {
#		if (defined $teamhash{$matches{$q}}) {
#			$teamhash{$matches{$q}}++;
#			$max = $teamhash{$matches{$q}} if ($teamhash{$matches{$q}} > $max);
#		} else {
#			$teamhash{$matches{$q}} = 1;
#		}
#	}
#	foreach my $t (keys %teamhash) {
#		next if ($teamhash{$t} == $max);
#		if ($teamhash{$t} < $max - 1) {
#			
#		}
#	}
	my $estr = "${event_year}${event_venue}";
	my $file = "/var/www/cgi-bin/matchdata/${estr}.dat";
	if (open my $fh, ">", $file) {
		$estr .= "_qm";
		for (my $i = 1; $i <= $num_matches; $i++) {
			my $k = "Q${i}R1";
			if (defined $matches{$k}) {
				print $fh "${estr}${i}_1 = $matches{$k}\n";
			}
			$k = "Q${i}R2";
			if (defined $matches{$k}) {
				print $fh "${estr}${i}_2 = $matches{$k}\n";
			}
			$k = "Q${i}R3";
			if (defined $matches{$k}) {
				print $fh "${estr}${i}_3 = $matches{$k}\n";
			}
			$k = "Q${i}B1";
			if (defined $matches{$k}) {
				print $fh "${estr}${i}_4 = $matches{$k}\n";
			}
			$k = "Q${i}B2";
			if (defined $matches{$k}) {
				print $fh "${estr}${i}_5 = $matches{$k}\n";
			}
			$k = "Q${i}B3";
			if (defined $matches{$k}) {
				print $fh "${estr}${i}_6 = $matches{$k}\n";
			}
		}
		close $fh;
		print "<H1>Event ${event_year}${event_venue} successfully saved. Click <A href=\"/cgi-bin/index.cgi\">here</A> to return to the home page</H1>\n";
		exit 0;
	} else {
		print "<H1>Error opening $file for writing: $!</H1>\n";
	}
}

print "</body>\n";
print "</html>\n";
