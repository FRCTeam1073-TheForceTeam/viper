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
my $jsFile='';
my $txtFile='';

for my $arg (@ARGV){
	$lang = $arg if ($arg =~ /^[a-z_]+$/);
	$jsFile = $arg if ($arg =~ /\.js$/);
	$txtFile = $arg if ($arg =~ /\.txt$/);
}

if (!$lang){
	print STDERR "No language argument\n";
	exit 1;
}

if (!$jsFile){
	print STDERR "No .js file argument\n";
	exit 1;
}

if (!$txtFile){
	print STDERR "No .text file argument\n";
	exit 1;
}


open my $fh, "<", $txtFile;
my @translations = grep(!/^\s*$/,<$fh>);
close $fh;

open $fh, "<", $jsFile;
my @jsLines = <$fh>;
close $fh;

my $inI18n=0;
my $inTranslation=0;
my $haveLang=0;
open $fh, ">", $jsFile;
for my $line (@jsLines){
	chomp $line;
	if(!$inI18n){
		$fh->print("$line\n");
		$inI18n=1 if ($line=~/(addI18n\s*\()|(statInfo\s*=)/);
	} else {
		if ($line =~ /(\}\))|(^\}$)/){
			$fh->print("$line\n");
			$inTranslation=0;
			$haveLang=0;
			$inI18n=0;
		} elsif ($line =~ /^\s*[a-z0-9_]+\:\{/){
			$inTranslation=1;
			$fh->print("$line\n");
		} elsif ($inTranslation and $line =~ /^\s*([a-z0-9_]+)\s*\:\s*['"](.*)['"]/){
			my $lineLang=$1;
			my $lineValue=$2;
			if ($lineLang eq $lang){
				if ($lineValue ne ""){
					$fh->print("$line\n");
					$haveLang=1;
				}
			} else {
				$fh->print("$line\n");
			}
		} elsif ($inTranslation) {
			my $translation=shift @translations;
			chomp $translation;
			$translation =~ s/\'/\\\'/g;
			$fh->print("\t\t$lang:'$translation',\n") if (!$haveLang);
			$inTranslation=0;
			$haveLang=0;
			$fh->print("$line\n");
		} else {
			$haveLang=0;
			$fh->print("$line\n");
		}
	}
}
close $fh;
