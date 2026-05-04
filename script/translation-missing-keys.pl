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

# Find all .js files with addI18n() or similar translation blocks
my @js_files;
find(sub {
	return unless /\.js$/;
	return if /\.min\.js$/;  # Skip minified files
	push @js_files, $File::Find::name;
}, $scan_dir);

# Process each file
for my $file (sort @js_files) {
	open my $fh, '<', $file or die "Cannot open $file: $!";
	my @lines = <$fh>;
	close $fh;

	my $in_i18n = 0;
	my $current_key = '';
	my %langs_in_key;
	my $line_num = 0;

	for my $line (@lines) {
		$line_num++;
		chomp $line;

		# Check if we're entering an i18n block (only addI18n, not data structures)
		if (!$in_i18n) {
			if ($line =~ /addI18n\s*\(/) {
				$in_i18n = 1;
			}
			next;
		}

		# Check if we're exiting the i18n block
		if ($in_i18n && ($line =~ /(\}\)?)|(^\s*\}\s*,?\s*$)|(^\s*\}\s*$)|(^\s*\}\))/)) {
			# Process the completed key
			if ($current_key) {
				check_key_translations($file, $current_key, \%langs_in_key, $line_num);
			}
			$current_key = '';
			%langs_in_key = ();
			$in_i18n = 0 if $line =~ /(\}\))|(^\s*\}\s*$)/;
			next;
		}

		# Check for a new translation key
		if ($in_i18n && $line =~ /^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*\{/) {
			# Process previous key if exists
			if ($current_key) {
				check_key_translations($file, $current_key, \%langs_in_key, $line_num);
			}
			$current_key = $1;
			%langs_in_key = ();
			next;
		}

		# Check for language entries within a key (including 'name:' as English in statInfo)
		if ($in_i18n && $current_key && $line =~ /^\s*([a-z0-9_]+)\s*:\s*['"]/) {
			my $lang = $1;
			# In statInfo objects, 'name' is used instead of 'en' for English
			$lang = 'en' if $lang eq 'name';
			$langs_in_key{$lang} = 1 if $REQUIRED_LANGS{$lang};
		}
	}

	# Process last key if file ended abruptly
	if ($current_key) {
		check_key_translations($file, $current_key, \%langs_in_key, $line_num);
	}
}

# Print results
print_results();

sub check_key_translations {
	my ($file, $key, $langs_found, $line_num) = @_;

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

	print "=== Translation Completeness Report ===\n\n";
	print "Supported Languages: " . join(', ', @SUPPORTED_LANGS) . "\n\n";

	if ($total_missing_keys == 0) {
		print "✅ All translation keys are complete!\n";
		print "   $total_files files checked\n";
		print "   All keys have all supported languages\n";
		return;
	}

	print "⚠️  Missing Translations Found\n";
	print "   Files with missing translations: $files_with_missing / $total_files\n";
	print "   Keys with missing languages: $total_missing_keys\n";
	print "   Total missing language entries: $total_missing_entries\n\n";

	# Print detailed report
	print "=== Detailed Report ===\n\n";

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
	print "=== Missing Translations by Language ===\n\n";
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
