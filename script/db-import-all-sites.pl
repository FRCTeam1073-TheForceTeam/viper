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
		if ($subdir !~ /^\./){
			print("IMPORTING $dir/$subdir/\n");
			`VIPER_DB_SITE=$subdir ./script/db-import-file.pl $dir/$subdir/*.* $dir/$subdir/*/*.*`;
		}
	}
}
