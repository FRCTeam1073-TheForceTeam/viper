#!/usr/bin/perl

use strict;
use autodie;
use Data::Dumper;

my $lang='';
my $file='';

for my $arg (@ARGV){
	$lang = $arg if ($arg =~ /^[a-z_]+$/);
	$file = $arg if ($arg =~ /\.js$/);
}

if (!$lang){
	print STDERR "No language argument\n";
	exit 1;
}

if (!$file){
	print STDERR "No file argument\n";
	exit 1;
}

my @translations = grep(!/^\s*$/,<STDIN>);
my $inI18n=0;
my $inTranslation=0;
my $haveLang=0;
open my $js, "<", $file;
while (my $line = <$js>) {
	chomp $line;
	if(!$inI18n){
		print "$line\n";
		$inI18n=1 if ($line=~/(addI18n\s*\()|(statInfo\s*=)/);
	} else {
		if ($line =~ /(\}\))|(^\}$)/){
			print "$line\n";
			$inTranslation=0;
			$haveLang=0;
			$inI18n=0;
		} elsif ($line =~ /^\s*[a-z0-9_]+\:\{/){
			$inTranslation=1;
			print "$line\n";
		} elsif ($inTranslation and $line =~ /^\s*([a-z0-9_]+)\s*\:\s*['"](.*)['"]/){
			my $lineLang=$1;
			my $lineValue=$2;
			if ($lineLang eq $lang){
				if ($lineValue ne ""){
					print "$line\n";
					$haveLang=1;
				}
			} else {
				print "$line\n";
			}
		} elsif ($inTranslation) {
			my $translation=shift @translations;
			chomp $translation;
			$translation =~ s/\'/\\\'/g;
			print "\t\t$lang:'$translation',\n" if (!$haveLang);
			$inTranslation=0;
			$haveLang=0;
			print "$line\n";
		} else {
			$haveLang=0;
			print "$line\n";
		}
	}
}
