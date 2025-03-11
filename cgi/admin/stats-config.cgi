#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use Fcntl qw(:flock SEEK_END);
use JSON qw(decode_json);
use Data::Dumper;
use lib '../../pm';
use webutil;
use db;
use csv;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new();

my $return = $cgi->param('return') || "/";
$webutil->error("Malformed return", $return) if ($return !~ /^\/([a-z]+\.html([\#\?][\#\?a-zA-Z0-9\-\_\=\&]+)?)?$/);

my $season = $cgi->param('season');
$webutil->error("Missing season") if (!$season);
$webutil->error("Malformed season", $season) if ($season !~ /^20[0-9]{2}(-[0-9]{2})?$/);

my $type = $cgi->param('type');
$webutil->error("Missing type") if (!$type);
$webutil->error("Type should be team or stats") if ($type !~ /^(team|stats|whiteboard|predictor)$/);

my $conf = $cgi->param('conf');
$webutil->error("Missing conf") if (!$conf);
my $parsed = eval{decode_json($conf)};
if ($@){
	$webutil->error("conf not in json format","$@");
}
if ($type =~ /^(whiteboard)$/){
	$webutil->error("Expected outer array") if (ref $parsed ne ref []);
	for my $field (@{$parsed}){
		$webutil->error("Unexpected stat", $field) if ($field !~ /^[a-zA-Z0-9_\-]+$/);
	}
} elsif ($type =~ /^(predictor)$/){
	$webutil->error("Expected outer map") if (ref $parsed ne ref {});
	for my $sectionName (keys %{$parsed}){
		my $section = $parsed->{$sectionName};
		$webutil->error("Expected array in each section:") if (ref $section ne ref []);
		$webutil->error("Empty section array") if (scalar @{$section} == 0);
		for my $field (@{$section}){
			$webutil->error("Unexpected stat", $field) if ($field !~ /^[a-zA-Z0-9_\-]+$/);
		}
	}
} else {
	$webutil->error("Expected outer map") if (ref $parsed ne ref {});
	for my $graph (keys %{$parsed}){
		my $graphConf = $parsed->{$graph};
		$webutil->error("Empty graph name") if ($graph =~ /^$/);
		$webutil->error("Expected :{ following '${graph}'") if (ref $graphConf ne ref {});
		$webutil->error("Expected only graph and data fields", $graph) if (scalar keys %{$graphConf} != 2);
		$webutil->error("${graph}.graph should be one of bar|boxplot|heatmap|stacked|stacked_percent|timeline", $graphConf->{"graph"}) if ($graphConf->{"graph"} !~ /^(bar|boxplot|heatmap|stacked|stacked_percent|timeline)$/);
		$webutil->error("Expected [ following data:") if (ref $graphConf->{"data"} ne ref []);
		$webutil->error("Empty data array") if (scalar @{$graphConf->{"data"}} == 0);
		for my $field (@{$graphConf->{"data"}}){
			$webutil->error("Unexpected graph field", $field) if ($field !~ /^[a-zA-Z0-9_\-]+$/);
		}
	}
}

my $dbh = $db->dbConnection();
if ($dbh){
	$db->upsert('siteconf', {
		'season'=>$season,
		'type'=>$type,
		'conf'=>$conf,
	});
	$db->commit();
} else {
	my $fileName = "../data/$season/$type.json";
	$webutil->error("Error opening $fileName for writing", "$!") if (!open my $fh, ">", $fileName);
	print $fh $conf;
	close $fh;
}

print "Content-type: text/html;charset=UTF-8\n\n";
print "<!DOCTYPE html>
<html>
<title>Configuration Saved</title>
<meta name=viewport content=width=device-width,initial-scale=1.0>
<meta charset=UTF-8>
<link rel=stylesheet href=/main.css>
<link rel=stylesheet href=/local.css>
<script src=/jquery.min.js></script>
<script src=/main.js></script>
<script src=/local.js></script>
<link rel=icon type=image/png href=/logo.png>
<meta http-equiv=refresh content='3; url=$return'></head>
<body>
<h1>Configuration Saved</h1>
<p>Redirecting back, please wait...</p>
</body>
</html>
";
