#!/usr/bin/perl

use lib './pm';
use db;

$db = db->new();
$db->schema();
