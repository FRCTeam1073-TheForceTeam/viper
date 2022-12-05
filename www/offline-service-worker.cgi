#!/usr/bin/perl -w

print "Content-type: text/javascript;charset=UTF-8\n\n";

my $tmpHome = `mktemp -d /tmp/XXXXXXXXXX`;
chomp $tmpHome;
my $gitdir = `readlink  -f ..`;
`HOME=$tmpHome git config --global --add safe.directory $gitdir`;

if ($ENV{REMOTE_ADDR} eq "127.0.0.1" or $ENV{DEBUG}){
	# For local development, don't use a service worker cache
	print "const CACHE_NAME = ''\n\n";
} else {
	my $hash = `HOME=$tmpHome git rev-parse HEAD`;
	chomp $hash;
	print "const CACHE_NAME = '$hash'\n\n";
}
print `cat offline-service-worker.js`;
`rm -rf $tmpHome`;