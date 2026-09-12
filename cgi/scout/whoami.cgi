#!/usr/bin/perl -w

use strict;
use warnings;

# Does nothing except exist. Apache guards this directory, so being able to read
# this at all is what proves the account holds the role -- the answer comes from
# the same rule that actually refuses the real actions, rather than from a second
# copy of the account list that could disagree with it.

print "Content-type: text/plain;charset=UTF-8\n\n";
print "scout";
