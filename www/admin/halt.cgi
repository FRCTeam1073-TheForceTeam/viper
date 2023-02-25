#!C:/xampp/perl/bin/perl.exe

use strict;
use warnings;
use CGI;

my $me = "/admin/halt.cgi";

my $cgi = CGI->new;
my $state = $cgi->param('halt');

# print web page beginning
print "Content-type: text/html; charset=UTF-8\n\n";
print "<!DOCTYPE html>\n";
print "<html>\n";
print "<head>\n";
print "<title>Halt Server - FRC Scouting App</title>\n";
print "</head>\n";
print "<body bgcolor=\"#dddddd\"><center>\n";

if ($state eq "active") {
	my $fh;
	if (!open($fh, ">", "../data/halt.txt")){
		print "<h3>Error opening halt signal file: $!</h3>\n";
		print "<body></html>\n";
		exit 0;
	}
	print $fh "halt\n";
	close($fh);

	print "<h3>Halt signal sent, shutting down</h3>\n";
	print "</body></html>\n";
	exit 0;
}

print "<h2>Are you sure you want to Halt this server?</h2>\n";
print "<br><br><br><br>\n";
print "<h2><a href=\"/\">No</a></h2>\n";
print "<br><br><br><br>\n";
print "<p><a href=\"${me}?halt=active\">Yes</a></p>\n";
print "</body></html>\n";
exit 0;
