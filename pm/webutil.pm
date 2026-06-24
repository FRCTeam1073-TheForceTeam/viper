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
	my ($self, $title, $help, $backUrl, $backLabel) = @_;
	print "Status: 500 Internal Server Error\n";
	print "Content-type: text/html; charset=UTF-8\n\n";
	print "<!DOCTYPE html>\n";
	print "<html>\n";
	print "<head>\n";
	print "<meta charset=UTF-8>\n";
	print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n";
	print "<title>".encode_entities($title)."</title>\n";
	# Pull in the site theme (CSS variables, base styling) so the page matches
	# the rest of the app instead of being unstyled black-on-white.
	print "<link rel=stylesheet href=/main.css>\n";
	print "<link rel=stylesheet href=/local.css>\n";
	print "<link rel=icon type=image/png href=/logo.png>\n";
	print "<style>\n";
	print ".errorCard{max-width:36em;margin:3em auto;padding:1.4em 1.6em;background:var(--section-bg-color);border:1px solid var(--main-border-color);border-radius:var(--radius-lg);box-shadow:var(--shadow)}\n";
	print ".errorCard h1{margin:0 0 .5em;font-size:1.4em;color:var(--button-disabled-decoration-color)}\n";
	# pre-wrap preserves the message's paragraph breaks but still wraps long
	# lines (e.g. URLs) instead of overflowing off the side of the page.
	print ".errorCard .errorHelp{margin:0;white-space:pre-wrap;line-height:1.5;opacity:.9}\n";
	print ".errorCard .errorBack{display:inline-block;margin-top:1.2em;padding:.5em 1em;font-weight:600;text-decoration:none;color:var(--accent-fg);background:var(--accent);border-radius:var(--radius)}\n";
	print ".errorCard .errorBack:hover{filter:brightness(1.1)}\n";
	print "</style>\n";
	print "</head>\n";
	print "<body><div id=main>\n";
	print "<div class=errorCard>\n";
	print "<h1>".encode_entities($title)."</h1>\n";
	print "<p class=errorHelp>".encode_entities($help||"")."</p>\n";
	# Optional link back to a sensible page (e.g. the event) so the user isn't
	# stranded on the error page.
	if ($backUrl) {
		$backLabel = "Return to the event page" if (!defined $backLabel);
		print "<a class=errorBack href=\"".encode_entities($backUrl)."\">".encode_entities($backLabel)."</a>\n";
	}
	print "</div>\n";
	print "</div></body>\n";
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
