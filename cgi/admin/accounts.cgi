#!/usr/bin/perl -w

use strict;
use warnings;
use Cwd qw(getcwd);
use JSON qw(encode_json);
use lib '../../pm';
use webutil;

# Reports which accounts hold which role, for the Site Configuration page.
# Read-only on purpose: Apache is what enforces these, from a vhost generated
# out of local.conf, so changing them means regenerating that config and
# reloading the server -- not something a web request should be doing. The page
# shows the current state and the exact steps instead.
#
# Lives under /admin/ so Apache keeps the account names away from everyone else.

my $webutil = webutil->new;

my %conf;
if (open(my $fh, '<', '../../local.conf')){
	while (my $line = <$fh>){
		$conf{$1} = $2 if $line =~ /^\s*(GUEST_USER|SCOUTING_USER|ADMIN_USER)\s*=\s*"?([^"\r\n]*?)"?\s*$/;
	}
	close $fh;
}

# The install directory, so the instructions can name the real path rather than
# a placeholder the reader has to translate.
my $root = getcwd();
$root =~ s/[\/\\]www[\/\\]admin$//;

print "Content-type: application/json;charset=UTF-8\n\n";
print encode_json({
	admin => [split(" ", $conf{ADMIN_USER} || "")],
	scout => [split(" ", $conf{SCOUTING_USER} || "")],
	guest => [split(" ", $conf{GUEST_USER} || "")],
	root  => $root,
	you   => ($ENV{REMOTE_USER} || ""),
});
