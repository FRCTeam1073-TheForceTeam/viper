#!C:/xampp/perl/bin/perl.exe

use strict;
use warnings;
use CGI;
use Data::Dumper;
use lib '../pm';
use webutil;
use csv;

my $cgi = CGI->new;
my $webutil = webutil->new;

my $file = $cgi->param('file');
$webutil->error("No file specified") if (!$file);
$webutil->error("Bad file name", $file) if ($file !~ /^20[0-9]{2}[a-zA-Z0-9\-]+\.[a-z]+\.csv$/);
$file = "data/$file";
$webutil->error("File does not exist", $file) if (! -e $file);


open my $fh, '<', $file or $webutil->error("Cannot open $file", "$!\n");
$/ = undef;
my $csv = csv->new(<$fh>);

sub unescapeField(){
    my ($s) = @_;
	$s =~ s/⏎/\r\n/g;
	$s =~ s/״/\"/g;
	$s =~ s/،/,/g;
    return $s;
}

sub escapeField(){
    my ($s) = @_;
    return $s if ($s !~ /[,\r\n\"]/);
	$s =~ s/\"/\"\"/g;
    return "\"$s\"";
}

print "Content-Disposition: attachment\n";
print "Content-Type: text/plain;charset=utf-8\n";
print "\n";

my $headers = $csv->getHeaders();
for my $i (0..$csv->getRowCount()){
    my $first = 1;
    for my $header (@{$headers}){
        print "," if (!$first);
        print &escapeField(&unescapeField($csv->getByName($i,$header)));
        $first = 0;
    }
    print "\n";
}