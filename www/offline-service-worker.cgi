#!/usr/bin/perl -w

print "Content-type: text/javascript;charset=UTF-8\n\n";

my $hash = `sh ../script/git-hash-working.sh`;
chomp $hash;
print "const CACHE_NAME = '$hash'\n\n";
print `cat offline-service-worker.js`;
