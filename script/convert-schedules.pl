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
	if (-e $newfile){
		print "Skipping $file because $newfile already exists\n";
		next;
	}
	die("Error opening $newfile for writing: $!") if (!open my $fh, ">", $newfile);
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
	if (-e $newfile){
		print "Skipping $file because $newfile already exists\n";
		next;
	}
	die("Error opening $newfile for writing: $!") if (!open my $fh, ">", $newfile);
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
	if (-e $allianceFile){
		print "Skipping $file because $allianceFile already exists\n";
		next;
	}
	die("Error opening $allianceFile for writing: $!") if (!open my $fh, ">", $allianceFile);
	print $fh "Alliance,Captain,First Pick,Second Pick,Won Quarter-Finals,Won Semi-Finals,Won Finals\n";
	for my $i (1..8){
		print $fh "$i,".$alliances->[$i-1].",,,\n"
	}
	close $fh;

	my $scheduleFile = $file;
	$scheduleFile =~ s/.*\//www\/data\//g;
	$scheduleFile =~ s/\.elims$/.schedule.csv/g;
	die("Error opening $scheduleFile for writing: $!") if (!open my $fh, ">>", $scheduleFile);
	my $matches = [[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6]];
	for my $i (1..scalar(@$matches)){
		my $r = $alliances->[$matches->[$i-1]->[0]-1];
		my $b = $alliances->[$matches->[$i-1]->[1]-1];
		print $fh "qf$i,$r,$b\n";
	}
	close $fh;

	`rm $file`;
}

my $semisFiles = [ split(/\n/, `find . -name '20*.semis'`) ];
for my $file (@$semisFiles){
	my $semis = `cat $file`;
	$semis =~ s/-/,/g;
	$semis = {map { $_ => 1 } split(/\n/, $semis)};
	my $allianceFile = $file;
	$allianceFile =~ s/.*\//www\/data\//g;
	$allianceFile =~ s/\.semis$/.alliances.csv/g;
	my $alliances = [ split(/\n/, `cat $allianceFile`) ];
	die("Error opening $allianceFile for writing: $!") if (!open my $fh, ">", $allianceFile);
	for my $alliance (@$alliances){
		if ($alliance =~ /^[^0-9]/){
			print $fh "$alliance\n";
		} else {
			$alliance = [ split(/,/,$alliance,-1) ];
			my $a = $alliance->[1].",".$alliance->[2].",".$alliance->[3];
			$alliance->[4] = $semis->{$a}?'1':'0';
			print $fh join(",",@$alliance)."\n";
		}
	}
	close $fh;

	my $scheduleFile = $file;
	$scheduleFile =~ s/.*\//www\/data\//g;
	$scheduleFile =~ s/\.semis$/.schedule.csv/g;
	die("Error opening $scheduleFile for writing: $!") if (!open my $fh, ">>", $scheduleFile);
	my $matchNum = 1;
	for my $n (1..3){
		my $matches = [[[1,8],[4,5]],[[2,7],[3,6]]];
		for my $i (1..scalar(@$matches)){
			my $r = $matches->[$i-1]->[0];
			$r = $alliances->[$r->[0]]->[4]==1?$alliances->[$r->[0]]:$alliances->[$r->[1]];
			$r = $r->[1].",".$r->[2].",".$r->[3];
			my $b = $matches->[$i-1]->[1];
			$b = $alliances->[$b->[0]]->[4]==1?$alliances->[$b->[0]]:$alliances->[$b->[1]];
			$b= $b->[1].",".$b->[2].",".$b->[3];

			print $fh "sf$matchNum,$r,$b\n";
			$matchNum++;
		}
	}
	close $fh;

	`rm $file`;
}
