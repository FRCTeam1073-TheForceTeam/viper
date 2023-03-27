#!/usr/bin/perl

package frcapi;

use strict;
use warnings;
use File::Slurp;
use LWP::UserAgent;
use lib '.';
use webutil;

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

my $localConf = read_file('../../local.conf');
my ($apiUser) = $localConf =~ /^FRC_API_USER\s*=\s*\"?([a-zA-Z0-9\-_]+)\"?\s*$/m;
my ($apiToken) = $localConf =~ /^FRC_API_TOKEN\s*=\s*\"?([a-zA-Z0-9\-_]+)\"?\s*$/m;
my $webutil = webutil->new;
$webutil->error("Missing API ".($apiUser?"Token":"User"), "FRC_API_USER=\"myusername\"\nFRC_API_TOKEN=\"myapitoken\"\n\nneeds to be added to local.conf after registering at\n\nhttps://frc-events.firstinspires.org/services/api/register") if (!$apiToken or !$apiUser);

my $ua = LWP::UserAgent->new;

sub fetchFromAPI(){
	my ($this, $url) = @_;
	$url = "https://frc-api.firstinspires.org/v3.0/$url";
	my $req = HTTP::Request->new(
		'GET',$url,["If-Modified-Since"=>""]
	);
	$req->authorization_basic($apiUser, $apiToken);
	my $response = $ua->request($req);
	$webutil->error("Error fetching $url", $response->message()) if ($response->is_error());
	sleep(1);
	return $response->content;
}

sub writeFileFromAPI(){
	my ($this, $url, $file) = @_;
	my $content = $this->fetchFromAPI($url);
	my $fh;
	my $pages = 1;
	if ($content =~ /\"pageTotal\"\:\s*([0-9]+)\,/){
		$pages = $1;
	}
	if ($pages > 1){
		$webutil->error("Error opening $file for writing", "$!") if (!open $fh, ">", $file);
		print $fh "{\"pageTotal\":$pages}\n";
		close $fh;
		my $pageFile = $file;
		$pageFile =~ s/(\.[0-9]+)?\.json/.1.json/g;
		$webutil->error("Error opening $pageFile for writing", "$!") if (!open $fh, ">", $pageFile);
		print $fh $content;
		close $fh;
		for (my $i=2; $i<=$pages; $i++){
			my $pageUrl = $url.($url=~/\?/?"&":"?")."page=$i";
			$content = $this->fetchFromAPI($pageUrl);
			my $pageFile = $file;
			$pageFile =~ s/(\.[0-9]+)?\.json/.$i.json/g;
			$webutil->error("Error opening $pageFile for writing", "$!") if (!open $fh, ">", $pageFile);
			print $fh $content;
			close $fh;
		}
	} else {
		$webutil->error("Error opening $file for writing", "$!") if (!open $fh, ">", $file);
		print $fh $content;
		close $fh;
	}
}

1;
