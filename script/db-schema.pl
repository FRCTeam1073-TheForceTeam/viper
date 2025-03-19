#!/usr/bin/perl

use strict;
use lib './pm';
use db;

$db = db->new();
$db->schema();
