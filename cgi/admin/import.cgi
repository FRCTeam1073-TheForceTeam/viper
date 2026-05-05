#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use MIME::Base64;
use Data::Dumper;
use File::Slurp;
use File::Path 'make_path';
use Fcntl qw(:flock SEEK_END);
use JSON;
use lib '../../pm';
use csv;
use webutil;
use db;
use dbimport;

my $webutil = webutil->new;
my $cgi = CGI->new;
my $db = db->new;
my $dbimport = dbimport->new;
my $dbh;

my $json = $cgi->param('json');
$webutil->error("Missing data parameter: json") if (!$json);

# Get and validate JSON upload before outputting anything
my $json_source;
my $upload_fh = $cgi->upload('json');
my $info = $cgi->uploadInfo($upload_fh);

if ($info){
	# If file was uploaded, use the temp file
	my $upload_file = $cgi->tmpFileName($json);
	open($json_source, '<:raw', $upload_file) or $webutil->error("Cannot open $upload_file", "$!");
} else {
	# Otherwise, use the JSON parameter directly (could be form data or already read)
	open($json_source, '<', \$json) or $webutil->error("Cannot open JSON parameter", "$!");
}

sub flushProgress {
	my ($fileName, $status, $message, $fileContents) = @_;
	my $display = $fileName;
	$display =~ s/^.*\///;
	my $escaped_display = $cgi->escapeHTML($display);
	my $escaped_message = $cgi->escapeHTML($message);
	print "<h2>$escaped_display</h2>\n";
	print "<p class=\"$status\">$escaped_message</p>\n";

	if ($fileContents) {
		my $escaped_contents = $cgi->escapeHTML($fileContents);
		print "<textarea readonly style=\"width: 100%; height: 200px; font-family: monospace; font-size: 12px;\">$escaped_contents</textarea>\n";
	}

	scrollToBottom();
}

sub scrollToBottom {
	print "<script>window.scrollTo(0, document.body.scrollHeight);</script>\n";
}

sub processFile {
	my ($fileName, $fileContents) = @_;
	my $openMode = ":encoding(UTF-8)";
	if ($fileContents =~ /^data:[a-z]+\/[a-z]+;base64,(.*)/){
		$fileContents = decode_base64($1);
		$openMode = ":raw"
	}

	eval {
		if($dbh){
			&writeDbData($fileName, $fileContents);
		} else {
			&writeFileData($fileName, $fileContents, $openMode);
		}
	};
	return $@ if $@;
	return undef;
}

sub writeFileData(){
	my ($fileName, $fileContents, $openMode) = @_;
	$fileName =~ s/^\/?data\//..\/data\//g;
	my $dir = $fileName;
	$dir =~ s/[^\/]*$//g;
	make_path($dir);

	my $lockFile = "$fileName.lock";
	open(my $lock, '>', $lockFile) or die "Cannot open $lockFile: $!";
	flock($lock, LOCK_EX) or die "Cannot lock $lockFile: $!";

	if ($fileName =~ /\.csv$/) {
		# For CSV files, merge based on primary keys
		$fileContents = csv->mergeFile($fileName, $fileContents);

		open(my $fh, ">$openMode", $fileName) or die "Error opening $fileName for writing: $!";
		print $fh $fileContents;
		close $fh;
		$webutil->commitDataFile($fileName, "import");
	} else {
		# For non-CSV files (images, json), just overwrite
		open(my $fh, ">$openMode", $fileName) or die "Error opening $fileName for writing: $!";
		print $fh $fileContents;
		close $fh;
	}

	close $lock;
	unlink($lockFile);
}

sub writeDbData(){
	my ($fileName, $fileContents) = @_;
	$dbimport->mergeImportCsvFile($fileName, $fileContents) if ($fileName =~ /\.csv$/);
	$dbimport->importImageFile($fileName, $fileContents) if ($fileName =~ /\.jpg$/);
}


# Output HTML header immediately for streaming response
print $cgi->header(-type => 'text/html; charset=utf-8');
print <<'HTML';
<!DOCTYPE html>
<html>
<head>
	<title>Import Progress</title>
	<style>
		body { font-family: sans-serif; margin: 20px; }
		h2 { margin: 15px 0 5px 0; }
		p { margin: 0 0 10px 0; padding: 5px; }
		.success { background: #d4edda; }
		.error { background: #f8d7da; color: #721c24; }
		.summary { margin-top: 20px; font-weight: bold; }
	</style>
</head>
<body>
	<h1>Import Progress</h1>
HTML

# Enable autoflush for streaming output
$| = 1;

$dbh = $db->dbConnection();

# Custom streaming JSON parser for flat key-value structure
my $buffer = "";
my $event = "";
my $errorCount = 0;
my $fileCount = 0;
my $pendingFileName = "";  # Track if we're waiting for a value from a previous key
my $is_final_buffer = 0;   # Flag to indicate we're processing the final buffer (no more chunks coming)

# Create a subroutine to process key-value pairs from the buffer
sub processKeyValuePairs {
	while (1) {
		# Skip leading whitespace and structural characters
		$buffer =~ s/^\s*//;

		# If buffer starts with { or , or }, skip it
		if ($buffer =~ /^[{,}]/) {
			printf STDERR "DEBUG: Skipping structural char, buffer len=%d\n", length($buffer);
			$buffer = substr($buffer, 1);
			$buffer =~ s/^\s*//;
			next;
		}

		# Try to match a key-value pair
		my $fileName;
		if ($pendingFileName) {
			# We're resuming extraction for a previous key match
			$fileName = $pendingFileName;
			printf STDERR "DEBUG: Resuming extraction for pending fileName: %s\n", $fileName;
		} elsif ($buffer =~ /^"([^"]+)"\s*:\s*/) {
			# Match a new key
			$fileName = $1;
			printf STDERR "DEBUG: Matched new key: %s\n", $fileName;
			$buffer = substr($buffer, $+[0]);  # Remove the matched key
			printf STDERR "DEBUG: After removing key, buffer len=%d\n", length($buffer);
		}

		if ($fileName) {
			# Now extract the value - it should be a quoted string
			printf STDERR "DEBUG: Looking for value, first 80 chars: %.80s\n", $buffer;
			# Find the closing quote by looking for the next key separator or end marker
			my $comma_quote_pos = index($buffer, '","');
			my $close_brace_pos = $is_final_buffer ? index($buffer, '"}') : -1;
			my $end_pos = -1;

			printf STDERR "DEBUG: comma_quote_pos=%d, close_brace_pos=%d, is_final=%d\n", $comma_quote_pos, $close_brace_pos, $is_final_buffer;

			# Determine which separator comes first
			if ($comma_quote_pos >= 0 && ($close_brace_pos < 0 || $comma_quote_pos < $close_brace_pos)) {
				# Found "," first
				$end_pos = $comma_quote_pos;
				printf STDERR "DEBUG: Using comma_quote_pos, end_pos=%d\n", $end_pos;
			} elsif ($close_brace_pos >= 0) {
				# Found "}" first (only in final buffer)
				$end_pos = $close_brace_pos;
				printf STDERR "DEBUG: Using close_brace_pos, end_pos=%d\n", $end_pos;
			}

			if ($end_pos > 0) {
				# Extract value from position 1 (after opening quote) to end_pos
				my $value = substr($buffer, 1, $end_pos - 1);
				printf STDERR "DEBUG: Raw extracted value (first 200 chars): %s\n", substr($value, 0, 200);
				printf STDERR "DEBUG: Raw extracted value length: %d chars\n", length($value);

				# Check for leading/trailing quotes
				if ($value =~ /^"/) {
					printf STDERR "DEBUG: WARNING - Value starts with quote!\n";
				}
				if ($value =~ /"$/) {
					printf STDERR "DEBUG: WARNING - Value ends with quote!\n";
				}

				$buffer = substr($buffer, $end_pos + 1);  # Remove value and closing quote from buffer
				printf STDERR "DEBUG: After removing value, buffer len=%d\n", length($buffer);
				$pendingFileName = "";  # Clear pending flag since we got the value

				# Properly unescape JSON string escapes
				$value =~ s/\\\\/\x00/g;    # Temporarily replace \\ with null byte
				$value =~ s/\\"/"/g;        # \" -> "
				$value =~ s/\\n/\n/g;       # \n -> newline
				$value =~ s/\\r/\r/g;       # \r -> carriage return
				$value =~ s/\\t/\t/g;       # \t -> tab
				$value =~ s/\\b/\b/g;       # \b -> backspace
				$value =~ s/\\f/\f/g;       # \f -> form feed
				$value =~ s/\\\//\//g;      # \/ -> /
				$value =~ s/\x00/\\/g;      # Replace null byte back with single backslash

				printf STDERR "DEBUG: Unescaped value length: %d\n", length($value);

				$fileCount++;
				printf STDERR "DEBUG: Processing file %d: %s\n", $fileCount, $fileName;

				# Validate file path
				if ($fileName !~ /^\/?data(\/20[0-9]{2})?\/([\.a-z0-9A-Z\-]+)\.(json|csv|jpg|webp)$/) {
					$errorCount++;
					printf STDERR "DEBUG: INVALID file path: %s\n", $fileName;
					flushProgress($fileName, "error", "Invalid file path");
				} else {
					# Extract event name
					if ($fileName =~ /data\/(20[0-9]{2}[a-z0-9\-]+)/) {
						$event = $1;
						printf STDERR "DEBUG: Extracted event: %s\n", $event;
					}

					# Process this file immediately
					my $error = processFile($fileName, $value);
					if ($error) {
						$errorCount++;
						printf STDERR "DEBUG: ERROR processing %s: %s\n", $fileName, $error;
						flushProgress($fileName, "error", $error);
					} else {
						printf STDERR "DEBUG: Successfully processed %s\n", $fileName;
						flushProgress($fileName, "success", "OK", $value);
					}
				}

				# Continue to next pair
				next;
			} else {
				# Value not complete yet, wait for more chunks (or done if final buffer)
				if ($is_final_buffer) {
					printf STDERR "DEBUG: Final buffer - value not complete (no separator found)\n";
					last;
				} else {
					printf STDERR "DEBUG: Value not complete yet for %s, buffer len=%d, waiting for more data\n", $fileName, length($buffer);
					$pendingFileName = $fileName;  # Save the fileName for next iteration
					last;
				}
			}
		} else {
			# No valid key found, might need more data
			printf STDERR "DEBUG: No valid key found, buffer len=%d\n", length($buffer);
			last;
		}
	}
}

# Read chunks and parse JSON key-value pairs
my $chunk;
while (read($json_source, $chunk, 8192)) {
	$buffer .= $chunk;
	printf STDERR "DEBUG: Read chunk of %d bytes, buffer now %d bytes\n", length($chunk), length($buffer);

	$is_final_buffer = 0;  # More chunks may be coming
	processKeyValuePairs();
}
close($json_source);
printf STDERR "DEBUG: Finished reading JSON, final buffer len=%d\n", length($buffer);

# Process any remaining data in the final buffer
if (length($buffer) > 0) {
	printf STDERR "DEBUG: Processing final buffer, length=%d\n", length($buffer);
	$buffer =~ s/^\s*//;
	$buffer =~ s/^[{,}]//;  # Skip structural characters
	$buffer =~ s/^\s*//;

	$is_final_buffer = 1;  # This is the last buffer, no more chunks coming
	processKeyValuePairs();
}

if (!$event) {
	$errorCount++;
	flushProgress("unknown", "error", "No files imported have an event name");
}

# Output final summary
print "\n";
print "<p class=\"summary\">";
my $eventInfo = $event ? "Event: $event" : "Event: Not found";
my $errorInfo = $errorCount == 0 ? "No errors" : "$errorCount error(s)";
print $cgi->escapeHTML("$fileCount file(s) processed. $errorInfo. $eventInfo");
print "</p>\n";
scrollToBottom();

# Redirect if successful
if ($event && $errorCount == 0) {
	print "<script>setTimeout(function() { window.location.href = '/event.html#$event'; }, 2000);</script>\n";
}

print "</body></html>\n";
