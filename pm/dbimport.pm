#!/usr/bin/perl

package dbimport;

use strict;
use warnings;
use Data::Dumper;
use lib '.';
use db;
use csv;

our $db = db->new();

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub getEventAndTable(){
	my($self, $file) = @_;
	my ($year, $event, $table) = $file =~ /^(?:.*\/)?(20[0-9]+)([^\.]+)\.([^\.]+)\.csv$/;
	$table = "$year$table" if ($table =~ /^scouting|pit|subjective$/);
	$event = "$year$event";
	return $event, $table;
}

sub deleteCsvFile(){
	my($self, $file, $commit) = @_;
	my ($event, $table) = $self->getEventAndTable($file);
	$dbimport::db->dbConnection()->prepare("DELETE FROM `$table` WHERE `site`=? AND `event`=?")->execute($db->getSite(), $event);
	$dbimport::db->commit() if ($commit);
}

sub importCsvFile(){
	my ($self, $file, $contents) = @_;
	my ($event, $table) = $self->getEventAndTable($file);
	$self->deleteCsvFile($file, 0);
	my $csv = csv->new($contents);

	for my $row (1..$csv->getRowCount()){
		my $data = $csv->getRowMap($row);
		$data->{'event'}=$event;
		eval {
			$dbimport::db->upsert($table, $data);
			1;
		} or do {
			my $error = $@;
			$row+=1;
			print STDERR "Failed on row: $row\n";
			print STDERR Dumper($data);
			die $error;
		}
	}
	$dbimport::db->commit();
}

sub importJsonFile(){
	my ($self, $f, $contents) = @_;

	my ($event, $fileType) = $f =~ /^(?:.*\/)?(20[0-9]+[^\.]+)\.(.+)\.json$/;
	my $json = scalar($contents);

	my $data = {
		'event' => $event,
		'file' => $fileType,
		'json' => $json
	};
	eval {
		$dbimport::db->upsert('apijson', $data);
		1;
	} or do {
		my $error = $@;
		print STDERR Dumper($data);
		die $error;
	};
	$dbimport::db->commit();
}

sub importImageFile(){
	my ($self, $f, $contents) = @_;

	my ($year, $team, $view) = $f =~ /^(?:.*\/)?(20[0-9]+)\/([0-9]+)(?:\-([a-z]+))?\.jpg$/;
	my $img = scalar($contents);
	$view = $view||"";

	my $data = {
		'year' => $year,
		'team' => $team,
		'view' => $view,
		'image' => $img
	};
	eval {
		$dbimport::db->upsert('images', $data);
		1;
	} or do {
		my $error = $@;
		$data->{'image'}='---BINARY DATA---';
		print STDERR Dumper($data);
		die $error;
	};
	$dbimport::db->commit();
}

sub importLocalJsFile(){
	my ($self, $contents) = @_;
	my $data = {
		'local_js' => scalar($contents)
	};
	eval {
		$dbimport::db->upsert('sites', $data);
		1;
	} or do {
		my $error = $@;
		print STDERR "Failed to store local.js\n";
		print STDERR Dumper($data);
		die $error;
	};
	$dbimport::db->commit();
}

sub importLocalCssFile(){
	my ($self, $contents) = @_;
	my $data = {
		'local_css' => scalar($contents)
	};
	eval {
		$dbimport::db->upsert('sites', $data);
		1;
	} or do {
		my $error = $@;
		print STDERR "Failed to store local.css\n";
		print STDERR Dumper($data);
		die $error;
	};
	$dbimport::db->commit();
}

sub importLocalBackgroundImageFile(){
	my ($self, $contents) = @_;
	my $data = {
		'background_image' => scalar($contents)
	};
	eval {
		$dbimport::db->upsert('sites', $data);
		1;
	} or do {
		my $error = $@;
		print STDERR "Failed to store local background image\n";
		die $error;
	};
	$dbimport::db->commit();
}
1;
