#!/usr/bin/perl

use strict;
use Data::Dumper;
use File::Slurp;
use lib './pm';
use db;

my $conf = read_file("local.conf", {binmode=>':encoding(UTF-8)'});
if ($conf !~ /^DB_SITE_NAME\s*=\s*\"?\*\"?$/gm){
	die 'DB_SITE_NAME="*" not present in local.conf';
}

die "Expect directory as first argument" if (scalar(@ARGV)==0);
my $dir = @ARGV[0];
die "'$dir' does not exist" if (! -e $dir);
die "'$dir' is not a directory" if (! -d $dir);
$dir =~ s|/+$||g;

opendir DIR,$dir;
my @subdirs = readdir(DIR);
close DIR;
for my $subdir (@subdirs){
	if(-d "$dir/$subdir"){
		if ($subdir =~ /^\./){
			# Skipping hidden files
		} elsif (! -d "$dir/$subdir/.git"){
			print "$dir/$subdir/.git does not exist, skipping $dir/$subdir\n";
		} else {
			print("EXPORTING $dir/$subdir/\n");
			unlink(glob("$dir/$subdir/*.* $dir/$subdir/*.*"));
			`./script/db-export-site.pl $dir/$subdir`
		}
	}
}
