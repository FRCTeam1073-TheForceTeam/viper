#!/usr/bin/perl

package db;

use strict;
use warnings;

use DBI;
use File::Slurp;

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub dbConnection {
	my $configFile = $INC{"db.pm"};
	$configFile =~ s/pm\/db\.pm/local.conf/g;
	my $conf = read_file($configFile);
	my($host) = $conf =~ /^MYSQL_HOST\s*=\s*\"?([^\"]+)\"?/gm;
	my($port) = $conf =~ /^MYSQL_PORT\s*=\s*\"?([^\"]+)\"?/gm;
	my($database) = $conf =~ /^MYSQL_DATABASE\s*=\s*\"?([^\"]+)\"?/gm;
	my($user) = $conf =~ /^MYSQL_USER\s*=\s*\"?([^\"]+)\"?/gm;
	my($password) = $conf	 =~ /^MYSQL_PASSWORD\s*=\s*\"?([^\"]+)\"?/gm;

	return 0 if (!$host or !$port or !$database or !$user or !$password);

	return DBI->connect_cached(
		"DBI:mysql:database=$database;host=$host;port=$port",
		$user,
		$password,
		{
			RaiseError => 1,
			PrintError => 0,
			mysql_enable_utf8 => 1
		}
	);
}

sub schema {
	my $dbh = &dbConnection();
	return if (!$dbh);

	my $tableOptions = "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

	 $dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				schedule
			(
				owner_id VARCHAR(16),
				event_id VARCHAR(64),
				match_id VARCHAR(8),
				r1 VARCHAR(8),
				r2 VARCHAR(8),
				r3 VARCHAR(8),
				b1 VARCHAR(8),
				b2 VARCHAR(8),
				b3 VARCHAR(8)
			)  $tableOptions
	 	"
	);
}

1;
