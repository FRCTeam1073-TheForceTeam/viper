#!/usr/bin/perl

use strict;
use autodie;

my $lang='';
my $file='';

for my $arg (@ARGV){
	$lang = $arg if ($arg =~ /^[a-z-]+$/);
	$file = $arg if ($arg =~ /\.js$/);
}

if (!$lang){
	print "No language argument\n";
	exit 1;
}

if (!$file){
	print "No file argument\n";
	exit 1;
}

my @translations = <STDIN>;
my $inI18n=0;
my $inTranslation=0;
my $haveLang=0;
open my $js, "<", $file;
while (my $line = <$js>) {
	chomp $line;
	if(!$inI18n){
		print "$line\n";
		$inI18n=1 if ($line=~/addI18n|statInfo/);
	} else {
		if ($line =~ /(\}\))|(^\}$)/){
			print "$line\n";
			$inTranslation=0;
			$haveLang=0;
			$inI18n=0;
		} elsif ($line =~ /^\s*[a-z0-9_]+\:\{/){
			$inTranslation=1;
			print "$line\n";
		} elsif ($inTranslation and $line =~ /^\s*([a-z_]+)\:\'(.*)',/){
			my $lineLang=$1;
			my $lineValue=$2;
			if ($lineLang eq $lang){
				if ($lineValue){
					print "$line\n";
					$haveLang=1;
				}
			} else {
				print "$line\n";
			}
		} else {
			my $translation="";
			while (!$translation){
				$translation = shift @translations;
				chomp $translation;
			}
			$translation =~ s/\'/\\\'/g;
			print "\t\t$lang:'$translation',\n" if ($inTranslation and !$haveLang);
			$inTranslation=0;
			$haveLang=0;
			print "$line\n";
		}
	}
}
