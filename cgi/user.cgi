#!/usr/bin/perl -w

use strict;
use warnings;

# Reports who is signed in and which of the three configured roles they hold, so
# the UI can hide abilities the server would refuse anyway. Role names are not
# fixed: they come from GUEST_USER / SCOUTING_USER / ADMIN_USER in local.conf.
# Apache is still the enforcement point -- this is only so the UI can agree with it.

my $user = $ENV{REMOTE_USER} || "";

my %conf;
if (open(my $fh, '<', '../local.conf')){
	while (my $line = <$fh>){
		$conf{$1} = $2 if $line =~ /^\s*(GUEST_USER|SCOUTING_USER|ADMIN_USER)\s*=\s*"?([^"\r\n]*?)"?\s*$/;
	}
	close $fh;
}
# Each setting holds a space-separated list, so a role can have any number of
# accounts -- "ADMIN_USER=\"admin taylor jane\"" gives all three admin rights.
# Apache reads the same lists: "Require user" accepts several names.
my @guest = split(" ", $conf{GUEST_USER} || "");
my @scout = split(" ", $conf{SCOUTING_USER} || "");
my @admin = split(" ", $conf{ADMIN_USER} || "");

sub isOneOf {
	my ($name, @names) = @_;
	return 0 if ($name eq "");
	for my $candidate (@names){
		return 1 if ($name eq $candidate);
	}
	return 0;
}

my $role;
if (!@guest && !@scout && !@admin){
	# No accounts configured at all: the site is deliberately unprotected.
	$role = "admin";
} elsif (isOneOf($user, @admin)){
	$role = "admin";
} elsif (isOneOf($user, @scout)){
	$role = "scout";
} elsif (isOneOf($user, @guest)){
	$role = "guest";
} elsif ($user eq ""){
	# Admitted by ALLOW_LOCAL or ALLOW_IPS rather than a password. Those rules sit
	# in the admin block too, so Apache really would allow admin paths -- report
	# that rather than show a UI narrower than the access.
	$role = "admin";
} else {
	# Authenticated, but not one of the configured names.
	$role = "guest";
}

sub esc {
	my $s = shift;
	$s = "" unless defined $s;
	$s =~ s/([\\"])/\\$1/g;
	$s =~ s/[[:cntrl:]]//g;
	return $s;
}

print "Content-type: application/json;charset=UTF-8\n\n";
printf '{"user":"%s","role":"%s"}', esc($user ne "" ? $user : "-"), esc($role);
