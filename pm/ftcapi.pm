#!/usr/bin/perl

package ftcapi;

use strict;
use warnings;
use Data::Dumper;
use File::Slurp;
use LWP::UserAgent;
use lib '.';
use webutil;
use db;

our $db = db->new;

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

my $localConf = read_file('../../local.conf');
my ($apiUser) = $localConf =~ /^FTC_API_USER\s*=\s*\"?([a-zA-Z0-9\-_]+)\"?\s*$/m;
my ($apiToken) = $localConf =~ /^FTC_API_TOKEN\s*=\s*\"?([a-zA-Z0-9\-_]+)\"?\s*$/m;
my $webutil = webutil->new;
$webutil->error("Missing API ".($apiUser?"Token":"User"), "FTC_API_USER=\"myusername\"\nFTC_API_TOKEN=\"myapitoken\"\n\nneeds to be added to local.conf after registering at\n\nhttps://ftc-events.firstinspires.org/services/api/register") if (!$apiToken or !$apiUser);

my $ua = LWP::UserAgent->new;

sub fetchFromAPI(){
	my ($this, $url) = @_;
	$url = "https://ftc-api.firstinspires.org/v2.0/$url";
	my $req = HTTP::Request->new(
		'GET',$url,["If-Modified-Since"=>""]
	);
	$req->authorization_basic($apiUser, $apiToken);
	my $response = $ua->request($req);
	$webutil->error("FTC API Error", "Error fetching $url: ".$response->message()."\n\n\n\nRefresh this page to try fetching from the API again.") if ($response->is_error());
	sleep(1);
	return $response->content;
}

sub writeFileFromAPI(){
	my ($this, $url, $file) = @_;
	my $content = $this->fetchFromAPI($url);
	my $pages = 1;
	my $filesWritten=0;
	if ($content =~ /^\{\"[A-Za-z0-9]+\"\:\[\]\}$/){
		# No content
		return $filesWritten;
	}
	if ($content =~ /\"pageTotal\"\:\s*([0-9]+)\,/){
		$pages = $1;
	}
	if ($pages > 1){

		$this->writeSingle($file, "{\"pageTotal\":$pages}\n");
		$filesWritten++;
		my $pageFile = $file;
		$pageFile =~ s/(\.[0-9]+)?\.json/.1.json/g;
		$this->writeSingle($pageFile, $content);
		$filesWritten++;
		for (my $i=2; $i<=$pages; $i++){
			my $pageUrl = $url.($url=~/\?/?"&":"?")."page=$i";
			$content = $this->fetchFromAPI($pageUrl);
			my $pageFile = $file;
			$pageFile =~ s/(\.[0-9]+)?\.json/.$i.json/g;
			$this->writeSingle($pageFile, $content);
			$filesWritten++;
		}
	} else {
		$this->writeSingle($file, $content);
		$filesWritten++;
	}
	return $filesWritten;
}

sub writeSingle(){
	my ($this, $fileName, $contents) = @_;
	if ($ftcapi::db->dbConnection()){
		my ($event,$file) = $fileName =~/^.*\/?(20[0-9]{2}[a-zA-Z0-9\-]*)\.([^\/]*)\.json$/;
		$ftcapi::db->upsert('apijson', {
			'event'=>$event,
			'file'=>$file,
			'json'=>$contents,
		});
		$ftcapi::db->commit();
	} else {
		$webutil->error("Error opening $fileName for writing", "$!") if (!open my $fh, ">", $fileName);
		print $fh $contents;
		close $fh;
	}
}

1;
