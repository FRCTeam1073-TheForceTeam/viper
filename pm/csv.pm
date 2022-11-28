#!/usr/bin/perl

package csv;

use Data::Dumper;

sub new {
	my ($class, $data) = @_;
	$data = [ map { [ split(/,/, $_, -1) ] } split(/[\r\n]+/, $data) ];
	my $headers = shift @{$data};
	$headerMap = { map { $headers->[$_] => $_ } 0..(scalar(@{$headers})-1) };
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

sub getValue(){
	my($self, $row, $col) = @_;
	return $self->{_headers}->[$col] if ($row == 0);
	return $self->{_data}->[$row-1]->[$col];
}

sub getByName(){
	my($self, $row, $colName) = @_;
	return $self->{_headers}->[$self->{_headerMap}->{$colName}] if ($row == 0);
	$row = $self->{_data}->[$row-1];
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

sub toString(){
	my($self) = @_;
	my $width = scalar @{$self->{_headers}};
	my $s = join(",", @{$self->{_headers}})."\n";
	for my $row (@{$self->{_data}}){
		my $rowWidth = scalar @$row;
		if ($width > $rowWidth){
			push(@$row, (("") x ($width - $rowWidth)))
		}
		$s = $s.join(",", @$row)."\n";
	}
	return $s;
}

1;
