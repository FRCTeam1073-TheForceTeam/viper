#!/usr/bin/perl

use strict;
use Data::Dumper;

my $files = [ split(/\n/, `find . -name '*.dat'`) ];

sub pairsToCsv(){
    my ($content, $file) = @_;
    my $csv = [["match","R1","R2","R2","B1","B2","B3"]];
    for my $line (split(/\n/, $content)){
        if ($line =~ /_qm([0-9]+)_([1-6]) *= *([0-9]+)/){
            my ($match, $pos, $team) = (int($1),int($2),$3);
            $csv->[$match] = ["qm$match"] if (!$csv->[$match]);
            $csv->[$match]->[$pos] = $team;
        } else {
            die "Unexpected line in $file: $line";
        }
    }
    for my $i (0..(scalar(@$csv)-1)){
        $csv->[$i] = join(",", @{$csv->[$i]});
    }
    $content = join("\n", @$csv)."\n";
    return $content;
}

for my $file (@$files){
    my $content = `cat $file`;
    $content = &pairsToCsv($content, $file) if ($content =~ /\=/);
    my $newfile = $file;
    $newfile =~ s/.*\//www\/data\//g;
    $newfile =~ s/\.dat$/.quals.csv/g;
    `rm $file`;
    die("Error opening $file for writing: $!") if (!open my $fh, ">", $newfile);
    print $fh $content;
    close $fh;
}
