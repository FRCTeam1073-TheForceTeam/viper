#!/usr/bin/perl

use strict;
use lib './pm';
use db;

my $db = db->new();
$db->schema();
