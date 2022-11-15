#!/usr/bin/perl

package csv;

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
	my( $self ) = @_;
	return scalar(@{$self->{_headers}})-1;
}

sub getValue(){
	my($self, $row, $col) = @_;
	return $self->{_headers}->[$col] if ($row == 0);
	return $self->{_data}->[$row-1]->[$col];
}

sub getByName(){
	my($self, $row, $colName) = @_;
	return $self->{_headers}->[$self->{_headerMap}->{$colName}] if ($row == 0);
	return $self->{_data}->[$row-1]->[$self->{_headerMap}->{$colName}];
}

sub getData() {
	my( $self ) = @_;
	return $self->{_data};
}

1;
