#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use JSON qw(decode_json);
use File::Slurp;
use lib '../../pm';
use webutil;
use db;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new();
my $localJsPath = '../../www/local.js';

$webutil->error("POST method required") if ($cgi->request_method() ne 'POST');

# Parse form parameters into config object
my $config = {
	ourTeam => $cgi->param('ourTeam'),
	showScoutingComments => $cgi->param('showScoutingComments') ? 1 : 0,
	showReviewRequest => $cgi->param('showReviewRequest') ? 1 : 0,
	analyticsOptOut => $cgi->param('analyticsOptOut') ? 1 : 0,
	transferHosts => [],
};

# Parse transferHosts from textarea (JSON array)
my $transferHostsJson = $cgi->param('transferHosts');
if ($transferHostsJson) {
	$config->{transferHosts} = eval { decode_json($transferHostsJson) };
	$webutil->error("Invalid transfer hosts format") if ($@);
}

# Validate configuration
&validateConfig($config);

# Read current JS, update with new config, save back
my $dbh = $db->dbConnection();
if ($dbh) {
	# Load from database
	my $sth = $dbh->prepare("SELECT `local_js` FROM `sites` WHERE `site`=?");
	$sth->execute($db->getSite());
	my $data = $sth->fetchall_arrayref();
	my $currentJs = ($data && @$data) ? $data->[0]->[0] : '';
	# Update and save to database
	my $newJs = &updateLocalJs($currentJs, $config);
	$db->upsert('sites', {
		'site' => $db->getSite(),
		'local_js' => $newJs,
	});
	$db->commit();
} else {
	# Load from file
	my $currentJs = '';
	if (-f $localJsPath) {
		$currentJs = read_file($localJsPath);
	}
	# Update and save to file
	my $newJs = &updateLocalJs($currentJs, $config);
	write_file($localJsPath, $newJs);
}

print "Location: ../local-config.html#saved\n\n";
exit 0;

sub validateConfig {
	my ($config) = @_;

	# Validate ourTeam
	if (exists $config->{ourTeam}) {
		if (defined $config->{ourTeam} && $config->{ourTeam} ne '') {
			my $team = $config->{ourTeam};
			$webutil->error("ourTeam must be numeric") if ($team !~ /^\d+$/);
			$webutil->error("ourTeam must be 0-99999") if ($team > 99999);
		}
	}

	# Validate booleans
	foreach my $field (qw(showScoutingComments showReviewRequest analyticsOptOut)) {
		if (exists $config->{$field}) {
			my $val = $config->{$field};
			$webutil->error("$field must be 0 or 1") if ($val !~ /^[01]$/);
		}
	}

	# Validate transferHosts
	if (exists $config->{transferHosts}) {
		my $hosts = $config->{transferHosts};
		$webutil->error("transferHosts must be an array") if (ref $hosts ne 'ARRAY');
		foreach my $host (@$hosts) {
			$webutil->error("Invalid hostname in transferHosts: '$host'") if ($host !~ /^((https?:\/\/)?)([a-zA-Z0-9\-\.\:]+)(\/?)$/);
		}
	}
}

sub updateLocalJs {
	my ($js, $config) = @_;

	# Build new variable assignments to append
	my $updates = '';

	if (exists $config->{ourTeam}) {
		$js =~ s/^var\s+ourTeam\s*=\s*.*?\n//m;
		my $val = $config->{ourTeam} // 0;
		$updates .= "var ourTeam = $val\n";
	}
	if (exists $config->{showScoutingComments}) {
		$js =~ s/^var\s+showScoutingComments\s*=\s*.*?\n//m;
		my $val = $config->{showScoutingComments} ? 'true' : 'false';
		$updates .= "var showScoutingComments = $val\n";
	}
	if (exists $config->{showReviewRequest}) {
		$js =~ s/^var\s+showReviewRequest\s*=\s*.*?\n//m;
		my $val = $config->{showReviewRequest} ? 'true' : 'false';
		$updates .= "var showReviewRequest = $val\n";
	}
	if (exists $config->{transferHosts}) {
		$js =~ s/^var\s+transferHosts\s*=\s*\[[\s\S]*?\]\n//m;
		$updates .= "var transferHosts = [\n";
		if (@{$config->{transferHosts}}) {
			foreach my $host (@{$config->{transferHosts}}) {
				$updates .= "\t\"$host\",\n";
			}
			$updates =~ s/,\n$/\n/;  # Remove trailing comma
		}
		$updates .= "]\n";
	}

	# Append updates to the end
	$js .= $updates;

	return $js;
}

1;
