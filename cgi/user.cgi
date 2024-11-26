#!/usr/bin/perl -w

use strict;
use warnings;

print "Content-type: text/plain;charset=UTF-8\n\n";
print $ENV{REMOTE_USER}||"-";
