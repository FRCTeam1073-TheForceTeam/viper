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

sub getLocalConf {
	my $file = $INC{"db.pm"};
	$file =~ s/pm\/db\.pm/local.conf/g;
	my $contents = read_file($file);
	print $contents;
	my ($host) = $contents =~ /^MYSQL_HOST\s*=\s*\"?([^\"]+)\"?/;
	print "MYSQL HOST: $host\n"
}


# sub dbConnection {
# 	my $localhost = hostname();
# 	my $dbhost = "localhost";
# 	$dbhost = 'db001osteraws.cct1yjxl5cn2.us-west-1.rds.amazonaws.com' if ($localhost =~ /osteraws/);
# 	return DBI->connect_cached(
# 		"DBI:mysql:database=doozoon;host=$dbhost;port=3306",
# 		'doozoon',
# 		'EyjFjARzZmdm',
# 		{
# 			RaiseError => 1,
# 			PrintError => 0,
# 			mysql_enable_utf8 => 1
# 		}
# 	);
# }

1;
