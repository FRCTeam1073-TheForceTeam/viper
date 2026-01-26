#!/usr/bin/perl

use strict;
use warnings;
use File::Find;
use Cwd qw(abs_path);

my $season = $ARGV[0];

# If no season provided, find the latest season directory
if (!defined $season || $season eq '') {
	my @dirs = ();
	opendir(my $dh, 'www') or die "Cannot open www directory: $!\n";
	while (my $dir = readdir($dh)) {
		next unless -d "www/$dir";
		if ($dir =~ /^20\d{2}(-\d{2})?$/) {
			push @dirs, $dir;
		}
	}
	closedir($dh);

	@dirs = sort @dirs;
	if (@dirs) {
		$season = $dirs[-1];
	} else {
		print "No valid season directory found in www/\n";
		exit 1;
	}
}

# Validate season format
unless ($season =~ /^20\d{2}(-\d{2})?$/) {
	print "Expected season to match ^20\\d{2}(-\\d{2})?\$\n";
	exit 1;
}

# Check if directory exists
unless (-d "www/$season") {
	print "Directory not found: www/$season\n";
	exit 1;
}

# Helper function to convert variable names to display names
sub format_name {
	my ($var) = @_;

	# Convert to lowercase, replace underscores with spaces, capitalize each word
	my $name = lc($var);
	$name =~ s/_/ /g;
	$name =~ s/\b(\w)/uc($1)/ge;

	# Special transformations
	$name =~ s/^Tele (.*)/$1 in Teleop/;
	$name =~ s/^Auto (.*)/$1 in Auto/;
	$name =~ s/\bPlace\b/Placed/g;
	$name =~ s/\bDrop\b/Dropped/g;
	$name =~ s/\bCollect\b/Collected/g;

	return $name;
}

# Helper function to determine type based on variable name and line
sub determine_type {
	my ($var, $line) = @_;

	my $type = '%';

	if ($var =~ /(min|max|fastest|slowest|most|least|best|worst)/) {
		$type = 'minmax';
	} elsif ($var =~ /(collect|score|place|shot|shoot|foul|count)/) {
		$type = 'avg';
	} elsif ($line =~ /(count|num)/) {
		$type = 'avg';
	} elsif ($var =~ /(created|modified)/) {
		$type = 'datetime';
	} elsif ($var =~ /(scouter|comments|match|team)/) {
		$type = 'text';
	} elsif ($line =~ /(textarea)/) {
		$type = 'text';
	}

	return $type;
}

# Read the aggregate-stats.js file
my $stats_file = "www/$season/aggregate-stats.js";
unless (-e $stats_file) {
	print "File not found: $stats_file\n";
	exit 1;
}

open(my $fh, '<', $stats_file) or die "Cannot open $stats_file: $!\n";
my $content = do { local $/; <$fh> };
close($fh);

# Extract variables from different sources
my %vars_seen;

# Extract from breakout array
if ($content =~ /breakout:\s*\[([^\]]+)\]/) {
	my $breakout = $1;
	while ($breakout =~ /([a-z0-9_]+(?:_[a-z0-9_]+)*)/gi) {
		$vars_seen{$1} = $breakout;
	}
}

# Extract from scout.aggregate properties
while ($content =~ /(?:scout|aggregate)\.([a-z0-9_]+)\b([^\n]*)/gi) {
	my $var = $1;
	my $line = $&;
	$vars_seen{$var} = $line unless $var eq 'old';
}

# Extract from scout.html
my $scout_file = "www/$season/scout.html";
if (-e $scout_file) {
	open(my $sh, '<', $scout_file) or die "Cannot open $scout_file: $!\n";
	while (my $line = <$sh>) {
		# Look for input/textarea name attributes
		if ($line =~ /<(?:input|textarea)[^>]+>/i) {
			while ($line =~ /name\s*=\s*[\'\"]?([A-Za-z0-9\-_]+)[\'\"]?/g) {
				my $var = $1;
				$vars_seen{$var} = $line unless $var eq 'old';
			}
		}
	}
	close($sh);
}

# Get sorted unique variables
my @vars = sort keys %vars_seen;

# Check each variable against the aggregate-stats.js and output new ones
foreach my $var (@vars) {
	# Check if variable already defined in aggregate-stats.js
	unless ($content =~ /^\s*$var\s*:\s*\{/m) {
		my $type = determine_type($var, $vars_seen{$var});
		my $name = format_name($var);

		print "\t$var:{\n";
		print "\t\ten:'$name',\n";
		print "\t\ttype:'$type',\n";
		print "\t},\n";
	}
}

exit 0;
