#!/usr/bin/perl -w

print "Content-type: text/javascript;charset=UTF-8\n\n";

if ($ENV{REMOTE_ADDR} eq "127.0.0.1" or $ENV{DEBUG}){
    # For local development, don't use a service worker cache
    print "const CACHE_NAME = ''\n\n";
} else {
    my $hash = `git rev-parse HEAD`;
    chomp $hash;
    print "const CACHE_NAME = '$hash $ENV{DEBUG}'\n\n";
}
print `cat offline-service-worker.js`;
