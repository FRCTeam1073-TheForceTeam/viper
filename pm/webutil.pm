#!/usr/bin/perl

use strict;
package webutil;
use Cwd;

use HTML::Entities;

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub error {
	my ($self, $title, $help) = @_;
	print "Content-type: text/html; charset=UTF-8\n\n";
	print "<!DOCTYPE html>\n";
	print "<html>\n";
	print "<head>\n";
	print "<meta charset=UTF-8>\n";
	print "<title>".encode_entities($title)."</title>\n";
	print "</head>\n";
	print "<body>\n";
	print "<h1 style=color:red>".encode_entities($title)."</h1>\n";
	print "<pre>".encode_entities($help||"")."</pre>\n";
	print "</body>\n";
	print "</html>\n";
	exit 0;
}

sub redirect {
	my ($self, $url) = @_;
	my $protocol = "http".(($ENV{'HTTPS'} or ($ENV{'HTTP_X_FORWARDED_PROTO'}||'') eq 'https')?"s":"");
	my $hostname = $ENV{'SERVER_NAME'};
	my $port = ($ENV{'HTTP_X_FORWARDED_FOR'} or $ENV{'SERVER_PORT'}=~/^80|443$/)?"":(":".$ENV{'SERVER_PORT'});
	$url = "$protocol://$hostname$port$url" if ($url =~ /^\//);
	print "Location: $url\n\n";
	exit 0;
}

sub notfound {
	print "Status: 404 Not Found\n";
	print "Content-Type: text/html\n\n";
	print "<h1>404 Not Found</h1>";
	exit 0;
}

sub commitDataFile {
	my ($self, $file, $message) = @_;
	$file =~ /((?:.*\/)?data\/)([^\/]+)/ or die "No data directory found in $file";
	my $datadir = $1;
	$file = $2;
	return if (!`sh -c 'command -v src'`);
	my $cwd = getcwd();
	chdir "data/" if (-d "data/");
	chdir "../data/" if (-d "../data/");
	my $srcOut = `src commit -m "$message" "$file" 2>\&1`;
	die "Could not track revision history: $srcOut" if ($?);
	chdir $cwd;
}

1;
