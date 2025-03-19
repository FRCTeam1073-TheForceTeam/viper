#!/usr/bin/perl

use strict;
use Data::Dumper;
use lib './pm';
use db;

my $db = db->new();
my $dbh = $db->dbConnection();

my $tables = $dbh->selectall_arrayref("show tables;");
my $site = $db->getSite();
for my $table (@$tables){
	$table = $table->[0];
	$dbh->prepare("DELETE FROM `$table` WHERE `site`=?")->execute($site);
	$db->commit();
}
