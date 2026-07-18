#!/usr/bin/perl

# Check all files that should have translations and report all keys
# that are not translated into one of the currently supported languages

use strict;
use autodie;
use File::Find;
use Data::Dumper;

# Extract supported languages from main-menu.html
my @SUPPORTED_LANGS;
open my $fh, '<', 'www/main-menu.html' or die "Cannot open www/main-menu.html: $!";
while (my $line = <$fh>) {
	if ($line =~ /<option value=([a-z_]+)>/) {
		push @SUPPORTED_LANGS, $1;
	}
}
close $fh;

my %REQUIRED_LANGS = map { $_ => 1 } @SUPPORTED_LANGS;

# Directory to scan
my $scan_dir = 'www';

# Results storage
my %missing_translations;  # {filename}{key}{lang} = 1
my %file_stats;            # {filename}{total_keys, missing_count}

# Find the most recent FRC season (4-digit year directories like 2026)
# and most recent FTC season (hyphenated year directories like 2025-26)
opendir(my $dh, $scan_dir) or die "Cannot open $scan_dir: $!";
my @dirs = grep { /^\d+(-\d+)?$/ && -d "$scan_dir/$_" } readdir($dh);
closedir($dh);

my $most_recent_frc = '';
my $most_recent_ftc = '';

for my $dir (@dirs) {
	if ($dir =~ /^(\d{4})$/) {
		# FRC format: single year
		$most_recent_frc = $dir if $dir gt $most_recent_frc;
	} elsif ($dir =~ /^(\d{4})-(\d{2})$/) {
		# FTC format: year range like 2025-26
		$most_recent_ftc = $dir if $dir gt $most_recent_ftc;
	}
}

my @current_seasons = grep { $_ } ($most_recent_frc, $most_recent_ftc);
die "No current season directories found in $scan_dir" unless @current_seasons;

# Find all .js files in current season directories
my @js_files;
find(sub {
	return unless /\.js$/;
	return if /\.min\.js$/;  # Skip minified files
	# Only include current season directories
	my $in_current = 0;
	for my $season (@current_seasons) {
		$in_current = 1 if $File::Find::name =~ m{/$season/};
	}
	return unless $in_current;
	push @js_files, $File::Find::name;
}, $scan_dir);

# Process each file
for my $file (sort @js_files) {
	open my $fh, '<', $file or die "Cannot open $file: $!";
	my @lines = <$fh>;
	close $fh;

	my $in_i18n = 0;
	my $i18n_type = '';  # 'addI18n' or 'named_object'
	my $depth = 0;  # 0=not in block, 1=top-level of object, 2=inside a key, 3+=nested
	my $current_key = '';
	my %langs_in_key;
	my $line_num = 0;

	for my $line (@lines) {
		$line_num++;
		chomp $line;

		# Check if we're entering an i18n block (addI18n or specific translation objects)
		if (!$in_i18n) {
			if ($line =~ /addI18n\s*\(/) {
				$in_i18n = 1;
				$i18n_type = 'addI18n';
				$depth = 0;
			} elsif ($line =~ /^var\s+(teamGraphs|aggregateGraphs|matchPredictorSections|statInfo)\s*=/) {
				$in_i18n = 1;
				$i18n_type = 'named_object';
				$depth = 0;
			}
		}

		# Process translation keys and language entries only within i18n blocks
		if ($in_i18n) {
			# Count braces to track nesting depth
			my $open_braces = ($line =~ tr/{//);
			my $close_braces = ($line =~ tr/}//);

			# Only look for new top-level keys when depth == 1 (directly inside the outer object)
			if ($depth == 1 && ($line =~ /^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*\{/ || $line =~ /^\s*"([^"]+)"\s*:\s*\{/)) {
				# Process previous key if exists
				if ($current_key) {
					check_key_translations($file, $current_key, \%langs_in_key, $line_num, $i18n_type);
				}
				$current_key = $1;
				%langs_in_key = ();
			}

			# Only look for language entries when depth == 2 (directly inside a key's body)
			if ($depth == 2 && $current_key && $line =~ /^\s*([a-z0-9_]+)\s*:\s*['"]/) {
				my $lang = $1;
				# In statInfo objects, 'name' is used instead of 'en' for English
				$lang = 'en' if $lang eq 'name';
				$langs_in_key{$lang} = 1 if $REQUIRED_LANGS{$lang};
			}

			# Update depth based on braces in this line
			$depth += $open_braces;
			$depth -= $close_braces;

			# When we exit a key (depth drops from 2 to 1), finalize it
			if ($depth == 1 && $current_key && $open_braces < $close_braces) {
				check_key_translations($file, $current_key, \%langs_in_key, $line_num, $i18n_type);
				$current_key = '';
				%langs_in_key = ();
			}

			# When we exit the entire block (depth drops to 0), close the block
			if ($depth == 0 && $in_i18n) {
				if ($current_key) {
					check_key_translations($file, $current_key, \%langs_in_key, $line_num, $i18n_type);
				}
				$current_key = '';
				%langs_in_key = ();
				$in_i18n = 0;
				$i18n_type = '';
			}
		}
	}

	# Process last key if file ended abruptly
	if ($current_key) {
		check_key_translations($file, $current_key, \%langs_in_key, $line_num, $i18n_type);
	}
}

# Print results
print_results();

sub check_key_translations {
	my ($file, $key, $langs_found, $line_num, $i18n_type) = @_;

	# Skip special keys that might not need all languages
	return if $key =~ /^_(MATCH|EVENT|TEAM|START|END|EXPECTEDNUM|ACTUALNUM|COUNT|SCOUTINGNAME|UPLOADCOUNT|LATERCOUNT|HISTORYCOUNT|QRNUM|QRTOTAL|TEAMNUM|TEAMCOLOR|TEAMCOLOR|FILE).*$/i;

	# Initialize file stats
	if (!exists $file_stats{$file}) {
		$file_stats{$file} = { total_keys => 0, missing_count => 0 };
	}
	$file_stats{$file}{total_keys}++;

	# Check for missing languages
	my @missing;
	for my $lang (@SUPPORTED_LANGS) {
		# For named objects (not addI18n), English is the default from the key name, so skip checking 'en'
		next if $i18n_type eq 'named_object' && $lang eq 'en';

		if (!exists $langs_found->{$lang}) {
			push @missing, $lang;
		}
	}

	if (@missing) {
		$file_stats{$file}{missing_count}++;
		$missing_translations{$file}{$key} = \@missing;
	}
}

sub print_results {
	my $total_files = keys %file_stats;
	my $files_with_missing = grep { $file_stats{$_}{missing_count} > 0 } keys %file_stats;
	my $total_missing_keys = 0;
	my $total_missing_entries = 0;

	# Calculate totals, excluding files with NO translations at all
	for my $file (keys %file_stats) {
		my $count = $file_stats{$file}{missing_count};

		# Skip files where ALL keys are missing ALL languages (no translations at all)
		if (exists $missing_translations{$file} && $count == $file_stats{$file}{total_keys}) {
			my $all_langs_missing = 0;
			KEY_CHECK: for my $key (keys %{$missing_translations{$file}}) {
				my @langs = @{$missing_translations{$file}{$key}};
				if (scalar @langs == scalar @SUPPORTED_LANGS) {
					$all_langs_missing++;
				} else {
					last KEY_CHECK;
				}
			}
			# If all keys are missing all languages, skip this file
			next if $all_langs_missing == $count;
		}

		$total_missing_keys += $count;
		if (exists $missing_translations{$file}) {
			for my $key (keys %{$missing_translations{$file}}) {
				$total_missing_entries += scalar @{$missing_translations{$file}{$key}};
			}
		}
	}

	if ($total_missing_keys == 0) {
		print "✅ All translation keys are complete!\n";
		print "   $total_files files checked\n";
		print "   All keys have all supported languages\n";
		return;
	}

	for my $file (sort keys %missing_translations) {
		my $missing_count = $file_stats{$file}{missing_count};
		my $total_keys = $file_stats{$file}{total_keys};

		# Skip files where ALL keys are missing ALL languages (no translations at all)
		if ($missing_count == $total_keys) {
			my $all_langs_missing = 0;
			KEY_CHECK: for my $key (keys %{$missing_translations{$file}}) {
				my @langs = @{$missing_translations{$file}{$key}};
				if (scalar @langs == scalar @SUPPORTED_LANGS) {
					$all_langs_missing++;
				} else {
					last KEY_CHECK;
				}
			}
			next if $all_langs_missing == $missing_count;
		}

		print "$file\n";
		print "  Missing: $missing_count / $file_stats{$file}{total_keys} keys\n";

		for my $key (sort keys %{$missing_translations{$file}}) {
			my @langs = @{$missing_translations{$file}{$key}};
			print "    ❌ $key: missing " . join(', ', @langs) . "\n";
		}
		print "\n";
	}

	# Summary by language
	my %lang_missing_count;
	for my $file (keys %missing_translations) {
		my $missing_count = $file_stats{$file}{missing_count};
		my $total_keys = $file_stats{$file}{total_keys};

		# Skip files where ALL keys are missing ALL languages (no translations at all)
		if ($missing_count == $total_keys) {
			my $all_langs_missing = 0;
			KEY_CHECK: for my $key (keys %{$missing_translations{$file}}) {
				my @langs = @{$missing_translations{$file}{$key}};
				if (scalar @langs == scalar @SUPPORTED_LANGS) {
					$all_langs_missing++;
				} else {
					last KEY_CHECK;
				}
			}
			next if $all_langs_missing == $missing_count;
		}

		for my $key (keys %{$missing_translations{$file}}) {
			for my $lang (@{$missing_translations{$file}{$key}}) {
				$lang_missing_count{$lang}++;
			}
		}
	}

	for my $lang (sort @SUPPORTED_LANGS) {
		my $count = $lang_missing_count{$lang} || 0;
		printf "  %s: %d missing\n", $lang, $count if $count > 0;
	}
	print "\n";
}
