#!C:/xampp/perl/bin/perl.exe -w

use File::Slurp;

print "Content-type: text/javascript;charset=UTF-8\n\n";

if ($ENV{REMOTE_ADDR} eq "127.0.0.1" or $ENV{DEBUG}){
	# For local development, don't use a service worker cache
	print "const CACHE_NAME = ''\n\n";
} else {
	my $head = read_file('../.git/HEAD');
	chomp $head;
	my $hash = "";
	if ($head =~ /^ref: (.*)$/g){
		$hash = read_file("../.git/$1");
		chomp $hash;
	}
	print "const CACHE_NAME = '$hash'\n\n";
}
print read_file('offline-service-worker.js');