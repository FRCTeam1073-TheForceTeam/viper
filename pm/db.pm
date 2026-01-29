#!/usr/bin/perl

package db;

use strict;
use warnings;

use DBI;
use File::Slurp;
use Data::Dumper;
use webutil;
use csv;

our $viper_database_name;
our $viper_site;
our $dbh;
our $config;

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub getConfig {
	return $db::config if ($db::config);
	$db::config = {};
	my $configFile = $INC{"db.pm"};
	$configFile =~ s/pm\/db\.pm/local.conf/g;
	my $conf = read_file($configFile);
	my @list = $conf =~/^([A-Z_]+)\s*=\s*\"?([^\"\r\n]+)\"?$/gm;
	while (my ($name,$value) = splice @list, 0, 2){
		$db::config->{$name} = $value;
	}
	return $db::config;
}

sub getSite {
	my $site =  getConfig()->{'DB_SITE_NAME'};
	$site = getConfig()->{'APACHE_SITE_NAME'} if (!$site);
	$site = "webscout" if (!$site );
	if ($site eq "*"){
		if (exists $ENV{'HTTP_HOST'}){
			my $host = $ENV{'HTTP_HOST'};
			$host =~ s/^www\.//gi;
			$site = lc($1) if ($host =~ /^([A-Za-z0-9\-]+)\./);
		} elsif (exists $ENV{'VIPER_DB_SITE'}){
			$site = lc($ENV{'VIPER_DB_SITE'});
		}
	}
	die "Could not determine viper site for db upload.  Consider setting the VIPER_DB_SITE environment variable." if ($site eq "*");
	return $site;
}

sub dbConnection {
	return $db::dbh if ($db::dbh);
	my $configFile = $INC{"db.pm"};
	$configFile =~ s/pm\/db\.pm/local.conf/g;
	my $conf = getConfig();
	my $host = $conf->{'MYSQL_HOST'};
	my $port = $conf->{'MYSQL_PORT'};
	$db::viper_database_name = $conf->{'MYSQL_DATABASE'};
	my $user = $conf->{'MYSQL_USER'};
	my $password = $conf->{'MYSQL_PASSWORD'};
	my $ssl = $conf->{'MYSQL_SSL'};

	return 0 if (!$host or !$port or !$db::viper_database_name or !$user or !$password);

	my $dsn = "DBI:mysql:database=$db::viper_database_name;host=$host;port=$port";

	# Enable SSL if configured
	if ($ssl && $ssl =~ /^(1|yes|true|t|y)$/i) {
		$dsn .= ";mysql_ssl=1";
	}

	$db::dbh = DBI->connect_cached(
		$dsn,
		$user,
		$password,
		{
			RaiseError => 1,
			PrintError => 0,
			mysql_enable_utf8mb4 => 1,
			AutoCommit => 0
		}
	);
	$db::dbh->prepare_cached("SET time_zone = '+00:00';")->execute();
	return $db::dbh;
}

sub printCsv(){
	my($self, $sth) = @_;

	binmode(STDOUT, ":utf8");
	my $headers = "Content-type: text/plain; charset=UTF-8\nContent-Disposition: attachment\n\n";
	return $self->writeCsv($sth, \*STDOUT, $headers, 0);
}

sub writeCsv(){
	my($self, $sth, $fh, $headers, $includeEvent) = @_;
	my $columns = $sth->{NAME};
	my $data = $sth->fetchall_arrayref();
	return 0 if (!scalar(@$data));
	$fh->print($headers) if ($headers);
	unshift(@$data, $columns);
	my $csv = csv->new($data);
	$fh->print($csv->toString($includeEvent));
	return 1;
}

sub upsert {
	my($self, $table, $data) = @_;
	delete($data->{""});
	my $conn = $self->dbConnection();
	$data->{'site'} = getSite();
	$data->{'site'} = "" if ($table eq 'apijson');
	my @allFields = keys(%$data);
	my $fields = join("`,`", @allFields);
	my $placeholders = join(",", map {"?"} @allFields);
	my $updates = join(",", map {"`$_`=?"} @allFields);
	my @values = ();
	push @values, map {$data->{$_}} @allFields;
	push @values, map {$data->{$_}} @allFields;

	my $done = 0;

	while (!$done){
		my $sth = $conn->prepare_cached("
			INSERT INTO `$table`
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
			if ($table =~ /^20[0-9]{2}(_[0-9]{2})?(pit|scouting|subjective)$/ and $error =~ /Unknown column '([^']+)'/i){
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
	return "TEXT" if ($input=~/^<textarea/i or $input =~ /type\s*=\s*["\']?hidden["\']?/i);
	return "VARCHAR(32)" if ($input =~ /type\s*=\s*["\']?(checkbox|radio)["\']?/i);
	return "VARCHAR(16)" if ($input =~ /type\s*=\s*["\']?number["\']?/i or $input =~ /class\s*=\s*["\']?([^"\']*\s)?num(\s[^"\']*)?["\']?/i);
	return "VARCHAR(256)";
}

sub schema {
	my ($self) = @_;
	my $dbh = &dbConnection();
	return if (!$dbh);

	my $tableOptions = "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

	print("Creating table `schedule`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				`schedule`			(
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
	eval {
		$dbh->do(
			"
				ALTER TABLE
					`schedule`
				MODIFY COLUMN
					`R3` VARCHAR(8) DEFAULT NULL,
				MODIFY COLUMN
					`B3` VARCHAR(8) DEFAULT NULL
			"
		);
		1;
	};
	$dbh->commit();

	print("Creating table `alliances`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				`alliances`
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
				`event`
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
	eval {
		$dbh->do(
			"
				ALTER TABLE
					`event`
				ADD COLUMN
					`orange_alliance_id` VARCHAR(32)
			"
		);
		1;
	};
	$dbh->commit();

	print("Creating table `apijson`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				`apijson`
			(
				`site` VARCHAR(16) NOT NULL,
				`event` VARCHAR(32) NOT NULL,
				`file` VARCHAR(32) NOT NULL,
				`json` MEDIUMTEXT NOT NULL,
				UNIQUE(`site`,`event`,`file`)
			)  $tableOptions
		"
	);
	$dbh->commit();

	print("Creating table `siteconf`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				`siteconf`
			(
				`site` VARCHAR(16) NOT NULL,
				`season` VARCHAR(7) NOT NULL,
				`type` VARCHAR(16) NOT NULL,
				`conf` MEDIUMTEXT NOT NULL,
				UNIQUE(`site`,`season`,`type`)
			)  $tableOptions
		"
	);
	$dbh->commit();

	print("Creating table `images`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				`images`
			(
				`site` VARCHAR(16) NOT NULL,
				`year` VARCHAR(4) NOT NULL,
				`team` VARCHAR(8) NOT NULL,
				`view` VARCHAR(8) NOT NULL,
				`image` MEDIUMBLOB NOT NULL,
				UNIQUE(`site`,`year`,`team`,`view`)
			)  $tableOptions
		"
	);
	eval {
		$dbh->do(
			"
				ALTER TABLE
					`images`
				MODIFY COLUMN
					`year` VARCHAR(7) NOT NULL
			"
		);
		1;
	};
	$dbh->commit();

	print("Creating table `sites`\n");
	$dbh->do(
		"
			CREATE TABLE IF NOT EXISTS
				`sites`
			(
				`site` VARCHAR(16) NOT NULL,
				`viewer_name` VARCHAR(32),
				`viewer_pass` VARCHAR(512),
				`scouter_name` VARCHAR(32),
				`scouter_pass` VARCHAR(512),
				`admin_name` VARCHAR(32),
				`admin_pass` VARCHAR(512),
				`local_js` MEDIUMTEXT,
				`local_css` MEDIUMTEXT,
				`background_image` MEDIUMBLOB,
				UNIQUE(`site`)
			)  $tableOptions
		"
	);
	eval {
		$dbh->do(
			"
				ALTER TABLE
					`sites`
				ADD COLUMN
					`logo_image` MEDIUMBLOB
			"
		);
		1;
	};
	$dbh->commit();


	my $wwwDir = $INC{"db.pm"};
	$wwwDir =~ s/pm\/db\.pm/www\//g;
	opendir(DIR, $wwwDir) || die "can't opendir $wwwDir: $!";
	my @seasons = grep { /^20[0-9]{2}(-[0-9]{2})?$/ && -d "$wwwDir/$_" } readdir(DIR);
	closedir DIR;
	@seasons = sort @seasons;
	for my $season (@seasons){
		my $seasonTableName = $season;
		$seasonTableName =~ s/-/_/g;
		print("Creating table `${seasonTableName}scouting`\n");
		$dbh->do(
			"
				CREATE TABLE IF NOT EXISTS
					`${seasonTableName}scouting`
				(
					`site` VARCHAR(16) NOT NULL,
					`event` VARCHAR(32) NOT NULL,
					`match` VARCHAR(8) NOT NULL,
					`team` VARCHAR(8) NOT NULL,
					`scouter` VARCHAR(32) NOT NULL DEFAULT '',
					INDEX(`site`,`event`),
					UNIQUE(`site`,`event`,`match`,`team`,`scouter`)
				)  $tableOptions
			"
		);
		if ( -e "$wwwDir/$season/scout.html"){
			my $contents = read_file("$wwwDir/$season/scout.html");
			my @inputs = $contents =~ /\<(?:input|textarea)[^\>]+\>/gmi;
			for my $input (@inputs){
				my $name = &getInputName($input);
				if ($name){
					my $type = &getInputType($input, $name);
					eval {
						$dbh->do(
							"
								ALTER TABLE
									${seasonTableName}scouting
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

		print("Creating table `${seasonTableName}pit`\n");
		$dbh->do(
			"
				CREATE TABLE IF NOT EXISTS
					`${seasonTableName}pit`
				(
					`site` VARCHAR(16) NOT NULL,
					`event` VARCHAR(32) NOT NULL,
					`team` VARCHAR(8) NOT NULL,
					`scouter` VARCHAR(32) NOT NULL DEFAULT '',
					INDEX(`site`,`event`),
					UNIQUE(`site`,`event`,`team`,`scouter`)
				)  $tableOptions
			"
		);
		if (-e "$wwwDir/$season/pit-scout.html"){
			my $contents = read_file("$wwwDir/$season/pit-scout.html");
			my @inputs = $contents =~ /\<(?:input|textarea)[^\>]+\>/gmi;
			for my $input (@inputs){
				my $name = &getInputName($input);
				if ($name){
					my $type = &getInputType($input, $name);
					eval {
						$dbh->do(
							"
								ALTER TABLE
									${seasonTableName}pit
								ADD COLUMN
									`$name` $type
							"
						);
						1;
					}
				}
			}
		}
		$dbh->commit();

		print("Creating table `${seasonTableName}subjective`\n");
		$dbh->do(
			"
				CREATE TABLE IF NOT EXISTS
					`${seasonTableName}subjective`
				(
					`site` VARCHAR(16) NOT NULL,
					`event` VARCHAR(32) NOT NULL,
					`team` VARCHAR(8) NOT NULL,
					`scouter` VARCHAR(32) NOT NULL DEFAULT '',
					INDEX(`site`,`event`),
					UNIQUE(`site`,`event`,`team`,`scouter`)
				)  $tableOptions
			"
		);
		if ( -e "$wwwDir/$season/subjective-scout.html"){
			my $contents = read_file("$wwwDir/$season/subjective-scout.html");
			my @inputs = $contents =~ /\<(?:input|textarea)[^\>]+\>/gmi;
			for my $input (@inputs){
				my $name = &getInputName($input);
				if ($name){
					my $type = &getInputType($input, $name);
					eval {
						$dbh->do(
							"
								ALTER TABLE
									${seasonTableName}subjective
								ADD COLUMN
									`$name` $type
							"
						);
						1;
					}
				}
			}
		}
		$dbh->commit();
	}
}

1;
