#!/usr/bin/perl

# USAGE EXAMPLE: Translate www/upload.js into Zulu
# 1. Make sure www/upload.js has is fully checked into git so that you can revert if needed.
# 2. ./script/translations-extract.pl www/upload.js zu
# 3. Paste the lines of English output into Google Translate and have it translate them into Zulu
# 4. Paste the translated Zulu into a file: /tmp/translations.txt
# 5. ./script/translations-import.pl www/upload.js /tmp/translations.txt zu
# 6. Check that Zulu translations got added to www/upload.js and commit it to git.

use strict;
use autodie;
use Data::Dumper;

my $lang='';
my $file='';

for my $arg (@ARGV){
	$lang = $arg if ($arg =~ /^[a-z_]+$/);
	$file = $arg if ($arg =~ /\.js$/);
}

if (!$file){
	print STDERR "No .js file argument\n";
	exit 1;
}
my $inI18n=0;
my $inTranslation=0;
my $haveLang=0;
my $english='';
open my $js, "<", $file;
while (my $line = <$js>) {
	chomp $line;
	if(!$inI18n){
		$inI18n=1 if ($line=~/(addI18n\s*\()|(statInfo\s*=)/);
	} else {
		if ($line =~ /(\}\))|(^\}$)/){
			$inTranslation=0;
			$haveLang=0;
			$inI18n=0;
		} elsif ($line =~ /^\s*[a-z0-9_]+\:\{/){
			$inTranslation=1;
		} elsif ($inTranslation and $line =~ /^\s*([a-z0-9_]+)\s*\:\s*['"](.*)['"]/){
			my $lineLang=$1;
			my $lineValue=$2;
			if ($lineLang eq $lang){
				if ($lineValue ne ""){
					$haveLang=1;
				}
			} elsif($lineLang eq 'en' or $lineLang eq 'name') {
				$english=$lineValue;
				$english=~s/\\//g;
			}
		} elsif ($inTranslation) {
			if($haveLang){
				print "#\n\n";
			} elsif ($english eq ""){
				print "?\n\n";
			} else {
				print "$english\n\n";
			}
			$inTranslation=0;
			$haveLang=0;
		} else {
			$haveLang=0;
		}
	}
}
