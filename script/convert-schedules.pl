#!/usr/bin/perl

use strict;
use Data::Dumper;

sub pairsToCsv(){
    my ($content, $file) = @_;
    my $csv = [["Match","R1","R2","R3","B1","B2","B3"]];
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

my $datFiles = [ split(/\n/, `find . -name '20*.dat'`) ];
for my $file (@$datFiles){
    my $content = `cat $file`;
    $content = &pairsToCsv($content, $file) if ($content =~ /\=/);
    my $newfile = $file;
    $newfile =~ s/.*\//www\/data\//g;
    $newfile =~ s/\.dat$/.schedule.csv/g;
    die("Error opening $file for writing: $!") if (!open my $fh, ">", $newfile);
    print $fh $content;
    close $fh;
    `rm $file`;
}

my $datFiles = [ split(/\n/, `find . -name '20*.txt'`) ];
for my $file (@$datFiles){
    my $content = `cat $file`;
    my $newfile = $file;
    $newfile =~ s/.*\//www\/data\//g;
    $newfile =~ s/\.txt$/.scouting.csv/g;
    die("Error opening $file for writing: $!") if (!open my $fh, ">", $newfile);
    print $fh $content;
    close $fh;
    `rm $file`;
}


my $elimsFiles = [ split(/\n/, `find . -name '20*.elims'`) ];
for my $file (@$elimsFiles){
    my $content = `cat $file`;
    $content =~ s/-/,/g;
    my $alliances = [ split(/\n/, $content) ];
    my $allianceFile = $file;
    $allianceFile =~ s/.*\//www\/data\//g;
    $allianceFile =~ s/\.elims$/.alliances.csv/g;
    die("Error opening $file for writing: $!") if (!open my $fh, ">", $allianceFile);
    print $fh "Alliance,Captain,First Pick,Second Pick,Won Quarter-Finals,Won Semi-Finals,Won Finals\n";
    for my $i (1..8){
        print $fh "$i,".$alliances->[$i-1].",,,\n"
    }
    close $fh;

    my $scheduleFile = $file;
    $scheduleFile =~ s/.*\//www\/data\//g;
    $scheduleFile =~ s/\.elims$/.schedule.csv/g;
    die("Error opening $file for writing: $!") if (!open my $fh, ">>", $scheduleFile);
    my $matches = [[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6]];
    for my $i (1..scalar(@$matches)){
        my $r = $alliances->[$matches->[$i-1]->[0]-1];
        my $b = $alliances->[$matches->[$i-1]->[1]-1];
        print $fh "qf$i,$r,$b\n"
    }
    close $fh;

    `rm $file`;
}