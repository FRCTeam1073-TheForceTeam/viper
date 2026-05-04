#!/usr/bin/perl

use strict;
package csv;

use Data::Dumper;
use File::Slurp;

sub new {
	my ($class, $data) = @_;
	$data = [ map { [ split(/,/, $_, -1) ] } split(/[\r\n]+/, $data) ] if (ref($data) ne 'ARRAY');
	my $headers = shift @{$data}||[];
	my $headerMap = { map { $headers->[$_] => $_ } 0..(scalar(@{$headers})-1) };
	my $self = {
		_data => $data,
		_headers => $headers,
		_headerMap => $headerMap,
	};
	bless $self, $class;
	return $self;
}

sub getRowCount(){
	my( $self ) = @_;
	return scalar(@{$self->{_data}});
}

sub getItemCount(){
	my($self, $row) = @_;
	return 0 if ($row >= $self->getRowCount());
	return scalar(@{$self->{_data}->[$row]});
}

sub getHeaderCount(){
	my($self) = @_;
	return scalar(@{$self->{_headers}})-1;
}

sub getHeaders(){
	my($self) = @_;
	return $self->{_headers};
}

sub getRowMap(){
	my($self, $row) = @_;
	my $data = {};
	for my $header (@{$self->{_headers}}){
		$data->{$header} = $self->getByName($row,$header);
	}
	return $data;
}

sub getValue(){
	my($self, $row, $col) = @_;
	return $self->{_headers}->[$col] if ($row == 0);
	return $self->{_data}->[$row-1]->[$col];
}

sub getByName(){
	my($self, $row, $colName) = @_;
	if (ref($row) ne 'ARRAY'){
		return $self->{_headers}->[$self->{_headerMap}->{$colName}] if ($row == 0);
		$row = $self->{_data}->[$row-1];
	}
	return "" if (! exists $self->{_headerMap}->{$colName});
	my $colInd = $self->{_headerMap}->{$colName};
	return "" if ($colInd >= scalar @$row);
	return $row->[$colInd];
}

sub getData(){
	my($self) = @_;
	return $self->{_data};
}

sub append(){
	my($self, $csv) = @_;
	for my $header (@{$csv->{_headers}}){
		if (!exists $self->{_headerMap}->{$header}){
			$self->{_headerMap}->{$header} = scalar @{$self->{_headers}};
			push(@{$self->{_headers}},$header);
		}
	}
	for my $i (1..$csv->getRowCount()){
		my $row = [("") x $self->getHeaderCount()];
		for my $header(@{$csv->{_headers}}){
			$row->[$self->{_headerMap}->{$header}] = $csv->getByName($i,$header);
		}
		push(@{$self->{_data}},$row)
	}
}

sub getHeadersWithData(){
	my($self, $includeEvent) = @_;
	my $containsData = { map { $_ => 0 } @{$self->{_headers}} };
	for my $row (@{$self->{_data}}){
		my $i=0;
		for my $field (@$row){
			$containsData->{$self->{_headers}->[$i]} = 1 if (defined $field and $field ne "");
			$i++;
		}
	}
	$containsData->{'site'} = 0;
	$containsData->{'event'} = 0 unless $includeEvent;
	my $withData = [];
	for my $header (keys %$containsData){
		push(@$withData, $header) if $containsData->{$header};
	}
	return $withData;
}

sub columnSortKey(){
	my($self,$name) = @_;
	return "!0-$name" if ($name eq 'site');
	return "!1-$name" if ($name eq 'event');
	return "!2-$name" if ($name eq 'match');
	return "!3-$name" if ($name eq 'team');
	return "!4-$name" if ($name eq 'created');
	return "!5-$name" if ($name eq 'modified');
	return "!6-$name" if ($name eq 'scouter');
	return "!7-$name" if ($name eq 'Match');
	return "!8-$name" if ($name eq 'R1');
	return "!8-$name" if ($name eq 'R2');
	return "!8-$name" if ($name eq 'R3');
	return "!9-$name" if ($name eq 'Alliance');
	return "!a-$name" if ($name eq 'name');
	return "!b-$name" if ($name eq 'location');
	return "~0-$name" if ($name eq 'Won Finals');
	return $name;
}

sub cmpRowsVals(){
	my($self,$a,$b,$name) = @_;
	my $aval = $self->getByName($a,$name);
	my $bval = $self->getByName($b,$name);

	return ($aval||"0")+0 <=> ($bval||"0")+0 if ($name eq "team" or $name eq "Alliance");

	if ($name eq "Match" or $name eq "match"){
		my ($around, $aname, $anum) = $aval =~ /^([0-9]*)(pm|qm|p|qf|sf|f)([0-9]+)/;
		my ($bround, $bname, $bnum) = $bval =~ /^([0-9]*)(pm|qm|p|qf|sf|f)([0-9]+)/;
		my $cmp;
		my $RoundNameOrder = {
			"pm"=>0,
			"qm"=>1,
			"p"=>2,
			"qf"=>3,
			"sf"=>4,
			"f"=>5
		};
		$cmp = $RoundNameOrder->{$aname||"pm"} <=> $RoundNameOrder->{$bname||"pm"};
		return $cmp if ($cmp != 0);

		$cmp = ($around||"0")+0 <=> ($bround||"0")+0;
		return $cmp if ($cmp != 0);

		return ($anum||"0")+0 <=> ($bnum||"0")+0;

	}

	return ($aval||"") cmp ($bval||"");
}

sub cmpRows(){
	my($self,$columns, $a,$b) = @_;
	my $cmp;

	for my $column (@$columns){
		$cmp = $self->cmpRowsVals($a,$b,$column);
		return $cmp if ($cmp != 0);
	}

	return 0;
}

sub toString(){
	my($self, $includeEvent) = @_;
	my $columns = $self->getHeadersWithData($includeEvent);
	$columns = [ sort { $self->columnSortKey($a) cmp $self->columnSortKey($b) } @$columns ];
	my $s = join(",", @$columns)."\n";

	my $rows = [ sort { $self->cmpRows($columns,$a,$b) } @{$self->{_data}} ];

	for my $row (@$rows){
		my $row_text = "";
		my $hasData = 0;
		for my $column (@$columns){
			my $val = $self->getByName($row,$column);
			if (defined $val and $val ne ""){
				$hasData = 1;
			} else {
				$val = "";
			}
			$row_text = "$row_text," if ($row_text);
			$row_text = "$row_text$val";
		}
		$s = "$s$row_text\n" if $hasData;
	}
	return $s;
}

sub getPrimaryKeyColumns(){
	my ($self, $type) = @_;

	return ['match', 'team', 'scouter'] if $type eq 'scouting';
	return ['team', 'scouter'] if $type eq 'pit';
	return ['team', 'scouter'] if $type eq 'subjective';
	return [] if $type eq 'event';
	return ['Match'] if $type eq 'schedule';
	return ['Alliance'] if $type eq 'alliances';
	return undef;
}

sub mergeFile(){
	my ($self, $filePath, $newCsvContents) = @_;

	# Extract type from filename (e.g., "2024cmp.scouting.csv" -> "scouting")
	my ($type) = $filePath =~ /\.([a-z]+)\.csv$/;
	die "Cannot determine CSV type from filename: $filePath" unless $type;

	my $keyColumns = $self->getPrimaryKeyColumns($type);
	die "Unknown CSV type: $type in file: $filePath" unless $keyColumns;

	# Read existing CSV or create empty one
	my $existingCsvData = -f $filePath ? scalar(read_file($filePath)) : "";
	my $existingCsv = csv->new($existingCsvData);
	my $newCsv = csv->new($newCsvContents);

	# First pass: merge headers from new into existing
	for my $header (@{$newCsv->{_headers}}){
		if (!exists $existingCsv->{_headerMap}->{$header}){
			$existingCsv->{_headerMap}->{$header} = scalar @{$existingCsv->{_headers}};
			push(@{$existingCsv->{_headers}},$header);
		}
	}

	# Build map of existing rows by primary key
	my $existingRowsByKey = {};
	for my $existingRowNum (1..$existingCsv->getRowCount()) {
		my @keyParts = map { $existingCsv->getByName($existingRowNum, $_) } @{$keyColumns};
		my $key = join("|", @keyParts);
		$existingRowsByKey->{$key} = $existingRowNum;
	}

	# Check if modified column exists
	my $hasModified = exists $existingCsv->{_headerMap}->{modified};

	# Merged result
	my $mergedData = [];
	my $processedKeys = {};

	# Process all new rows
	for my $newRowNum (1..$newCsv->getRowCount()) {
		my @keyParts = map { $newCsv->getByName($newRowNum, $_) } @{$keyColumns};
		my $key = join("|", @keyParts);
		$processedKeys->{$key} = 1;

		if (exists $existingRowsByKey->{$key}) {
			# Key exists in both - need to decide which to keep
			my $existingRowNum = $existingRowsByKey->{$key};
			my $keepNew = 1; # Default: new wins

			if ($hasModified) {
				my $existingModified = $existingCsv->getByName($existingRowNum, 'modified');
				my $newModified = $newCsv->getByName($newRowNum, 'modified');

				# Both have dates - keep the newer one
				if ($existingModified ne "" && $newModified ne "") {
					$keepNew = 0 if ($existingModified gt $newModified);
				}
				# One has date - keep the one with date
				elsif ($existingModified ne "") {
					$keepNew = 0;
				}
				# else: both blank or new has date - new wins
			}

			# Add the winning row
			if ($keepNew) {
				my $row = [("") x scalar(@{$existingCsv->{_headers}})];
				for my $header(@{$newCsv->{_headers}}){
					$row->[$existingCsv->{_headerMap}->{$header}] = $newCsv->getByName($newRowNum,$header);
				}
				push(@$mergedData, $row);
			} else {
				# Keep existing row, extend it if needed
				my $existingRow = $existingCsv->{_data}->[$existingRowNum - 1];
				while (scalar(@$existingRow) < scalar(@{$existingCsv->{_headers}})) {
					push(@$existingRow, "");
				}
				push(@$mergedData, $existingRow);
			}
		} else {
			# Key only in new - add it
			my $row = [("") x scalar(@{$existingCsv->{_headers}})];
			for my $header(@{$newCsv->{_headers}}){
				$row->[$existingCsv->{_headerMap}->{$header}] = $newCsv->getByName($newRowNum,$header);
			}
			push(@$mergedData, $row);
		}
	}

	# Add remaining existing rows that weren't processed
	for my $existingRowNum (1..$existingCsv->getRowCount()) {
		my @keyParts = map { $existingCsv->getByName($existingRowNum, $_) } @{$keyColumns};
		my $key = join("|", @keyParts);

		if (!exists $processedKeys->{$key}) {
			my $existingRow = $existingCsv->{_data}->[$existingRowNum - 1];
			while (scalar(@$existingRow) < scalar(@{$existingCsv->{_headers}})) {
				push(@$existingRow, "");
			}
			push(@$mergedData, $existingRow);
		}
	}

	# Replace data with merged result
	$existingCsv->{_data} = $mergedData;

	return $existingCsv->toString();
}

1;
