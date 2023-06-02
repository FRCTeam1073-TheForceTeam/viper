#!/usr/bin/perl

package db;

use strict;
use warnings;

use DBI;
use File::Slurp;
use Data::Dumper;

our $viper_database_name;
our $viper_site;
our $dbh;

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub dbConnection {
	return $db::dbh if ($db::dbh);
	my $configFile = $INC{"db.pm"};
	$configFile =~ s/pm\/db\.pm/local.conf/g;
	my $conf = read_file($configFile);
	my($host) = $conf =~ /^MYSQL_HOST\s*=\s*\"?([^\"]+)\"?/gm;
	my($port) = $conf =~ /^MYSQL_PORT\s*=\s*\"?([^\"]+)\"?/gm;
	($db::viper_database_name) = $conf =~ /^MYSQL_DATABASE\s*=\s*\"?([^\"]+)\"?/gm;
	my($user) = $conf =~ /^MYSQL_USER\s*=\s*\"?([^\"]+)\"?/gm;
	my($password) = $conf	 =~ /^MYSQL_PASSWORD\s*=\s*\"?([^\"]+)\"?/gm;
	($db::viper_site) = $conf =~ /^APACHE_SITE_NAME\s*=\s*\"?([^\"]+)\"?/gm;
	$db::viper_site = "webscout" if (!$db::viper_site);

	return 0 if (!$host or !$port or !$db::viper_database_name or !$user or !$password);

	$db::dbh = DBI->connect_cached(
		"DBI:mysql:database=$db::viper_database_name;host=$host;port=$port",
		$user,
		$password,
		{
			RaiseError => 1,
			PrintError => 0,
			mysql_enable_utf8mb4 => 1,
			AutoCommit => 0
		}
	);
	return $db::dbh;
}

sub upsert {
	my($self, $table, $data) = @_;
	my $conn = $self->dbConnection();
	$data->{'site'} = $db::viper_site;
	my @allFields = keys(%$data);
	my $fields = join("`,`", @allFields);
	my $placeholders = join(",", map {"?"} @allFields);
	my @updateFields = grep(!/^(site|event|Match|Alliance)$/, @allFields);
	my $updates = join(",", map {"`$_`=?"} @updateFields);
	my @values = ();
	push @values, map {$data->{$_}} @allFields;
	push @values, map {$data->{$_}} @updateFields;

	my $done = 0;

	while (!$done){
		my $sth = $conn->prepare_cached("
			INSERT INTO $table
				(`$fields`)
			VALUES
				($placeholders)
			ON DUPLICATE KEY UPDATE
				$updates
			;
		");
		eval {
			$sth->execute(@values);
			$done = 1;
			1;
		} or do {
			my $error = $@;
			if ($error =~ /Unknown column '([^']+)'/i){
				my $column = $1;
				my $type = "VARCHAR(256)";
				$dbh->do("
					ALTER TABLE
						`$table`
					ADD COLUMN
						`$column` $type
				");
			} else {
				die $error;
			}
		}
	}
}

sub commit(){
	my $dbh = &dbConnection();
	return if (!$dbh);
	$dbh->commit();
}

sub getInputName(){
	my ($input) = @_;
	my ($name) = $input =~ /name\s*=\s*[\'\"]?([A-Za-z0-9\-_]+)[\'\"]?\b/i;
	return $name;
}
sub getInputType(){
	my ($input, $name) = @_;
	return "TIMESTAMP" if ($name eq 'created' or $name eq 'modified');
	return "VARCHAR(2048)" if ($input=~/^<textarea/i);
	return "VARCHAR(256)";
}

sub schema {
	my $dbh = &dbConnection();
	return if (!$dbh);

	my $tableOptions = "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

	print("Creating table `schedule`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				schedule
			(
				`site` VARCHAR(16) NOT NULL,
				`event` VARCHAR(32) NOT NULL,
				`Match` VARCHAR(8) NOT NULL,
				`R1` VARCHAR(8) NOT NULL,
				`R2` VARCHAR(8) NOT NULL,
				`R3` VARCHAR(8) NOT NULL,
				`B1` VARCHAR(8) NOT NULL,
				`B2` VARCHAR(8) NOT NULL,
				`B3` VARCHAR(8) NOT NULL,
				INDEX(`site`,`event`),
				UNIQUE(`site`,`event`,`Match`)
			)  $tableOptions
	 	"
	);
	$dbh->commit();

	print("Creating table `alliances`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				alliances
			(
				`site` VARCHAR(16) NOT NULL,
				`event` VARCHAR(32) NOT NULL,
				`Alliance` VARCHAR(4) NOT NULL,
				`Captain` VARCHAR(8) NOT NULL,
				`First Pick` VARCHAR(8) NOT NULL,
				`Second Pick` VARCHAR(8) NOT NULL,
				`Won Quarter-Finals` VARCHAR(1),
				`Won Semi-Finals` VARCHAR(1),
				`Won Playoffs Round 1` VARCHAR(1),
				`Won Playoffs Round 2` VARCHAR(1),
				`Won Playoffs Round 3` VARCHAR(1),
				`Won Playoffs Round 4` VARCHAR(1),
				`Won Playoffs Round 5` VARCHAR(1),
				`Won Finals` VARCHAR(1),
				INDEX(`site`,`event`),
				UNIQUE(`site`,`event`,`Alliance`)
			)  $tableOptions
	 	"
	);
	$dbh->commit();

	print("Creating table `event`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				event
			(
				`site` VARCHAR(16) NOT NULL,
				`event` VARCHAR(32) NOT NULL,
				`name` VARCHAR(256),
				`location` VARCHAR(256),
				`start` VARCHAR(12),
				`end` VARCHAR(12),
				`blue_alliance_id` VARCHAR(32),
				`first_inspires_id` VARCHAR(32),
				UNIQUE(`site`,`event`)
			)  $tableOptions
	 	"
	);
	$dbh->commit();

	my $wwwDir = $INC{"db.pm"};
	$wwwDir =~ s/pm\/db\.pm/www\//g;
	opendir(DIR, $wwwDir) || die "can't opendir $wwwDir: $!";
	my @years = grep { /^20[0-9]{2}$/ && -d "$wwwDir/$_" } readdir(DIR);
	closedir DIR;
	@years = sort @years;
	for my $year (@years){
		if ( -e "$wwwDir/$year/scout.html"){
		print("Creating table `${year}scouting`\n");
			$dbh->do(
				"
					CREATE TABLE IF NOT EXISTS
						${year}scouting
					(
						`site` VARCHAR(16) NOT NULL,
						`event` VARCHAR(32) NOT NULL,
						`match` VARCHAR(8) NOT NULL,
						`team` VARCHAR(8) NOT NULL,
						`scouter` VARCHAR(32) NOT NULL,
						INDEX(`site`,`event`),
						UNIQUE(`site`,`event`,`match`,`team`,`scouter`)
					)  $tableOptions
				"
			);
			my $contents = read_file("$wwwDir/$year/scout.html");
			my @inputs = $contents =~ /\<(?:input|textarea)[^\>]+\>/gmi;
			for my $input (@inputs){
				my $name = &getInputName($input);
				if ($name){
					my $type = &getInputType($input, $name);
					eval {
						$dbh->do(
							"
								ALTER TABLE
									${year}scouting
								ADD COLUMN
									`$name` $type
							"
						);
						1;
					}
				}
			}
			$dbh->commit();
		}
		if ( -e "$wwwDir/$year/pit-scout.html"){
			print("Creating table `${year}pit`\n");
			$dbh->do(
				"
					CREATE TABLE IF NOT EXISTS
						${year}pit
					(
						`site` VARCHAR(16) NOT NULL,
						`event` VARCHAR(32) NOT NULL,
						`team` VARCHAR(8) NOT NULL,
						`scouter` VARCHAR(32) NOT NULL,
						INDEX(`site`,`event`),
						UNIQUE(`site`,`event`,`team`,`scouter`)
					)  $tableOptions
				"
			);
			my $contents = read_file("$wwwDir/$year/pit-scout.html");
			my @inputs = $contents =~ /\<(?:input|textarea)[^\>]+\>/gmi;
			for my $input (@inputs){
				my $name = &getInputName($input);
				if ($name){
					my $type = &getInputType($input, $name);
					eval {
						$dbh->do(
							"
								ALTER TABLE
									${year}pit
								ADD COLUMN
									`$name` $type
							"
						);
						1;
					}
				}
			}
			$dbh->commit();
		}
	}
}

1;
