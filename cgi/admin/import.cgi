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
		print "<textarea readonly>$escaped_contents</textarea>\n";
	}

	scrollToBottom();
	STDOUT->flush();  # Explicitly flush output to browser
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
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel=stylesheet href=/main.css>
<link rel=stylesheet href=/local.css>
<link rel="stylesheet" href="/import.css">
<script src=/jquery.min.js></script>
<script src=/main.js></script>
</head>
<body>
<h1>Import Progress</h1>
HTML

# Enable autoflush for streaming output
$| = 1;

$dbh = $db->dbConnection();

# Helper function to format bytes as MB
sub formatBytes {
	my ($bytes) = @_;
	return sprintf("%.2f MB", $bytes / (1024 * 1024));
}

# Custom streaming JSON parser for flat key-value structure
my $buffer = "";
my $event = "";
my $errorCount = 0;
my $fileCount = 0;
my $pendingFileName = "";  # Track if we're waiting for a value from a previous key
my $pendingValue = 0;  # Track if we're in the middle of extracting a value
my $is_final_buffer = 0;   # Flag to indicate we're processing the final buffer (no more chunks coming)

# Create a subroutine to process key-value pairs from the buffer
sub processKeyValuePairs {

	while (1) {
		# Skip leading whitespace and structural characters
		$buffer =~ s/^\s*//;

		# If buffer starts with { or , or }, skip it
		if ($buffer =~ /^[{,}]/) {
			$buffer = substr($buffer, 1);
			$buffer =~ s/^\s*//;
			next;
		}

		# Try to match a key-value pair
		my $fileName;
		if ($pendingFileName) {
			# We're resuming extraction for a previous key match
			$fileName = $pendingFileName;
		} elsif ($buffer =~ /^"([^"]+)"\s*:\s*/) {
			# Match a new key (JSON keys are always double-quoted)
			$fileName = $1;
			$buffer = substr($buffer, $+[0]);  # Remove the matched key and colon
		}

		if ($fileName) {
			# Now extract the value - it should be a quoted string (JSON always uses double quotes)

			if ($pendingValue) {
				# Resume from a previous incomplete value - we already consumed the opening quote
			} elsif ($buffer =~ /^"/) {
				# Found opening double quote for value
				$buffer = substr($buffer, 1);  # Remove the opening quote from buffer
				$pendingValue = 1;  # Mark that we're extracting a value
			}

			if ($pendingValue) {
				# Scan buffer for closing unescaped double quote using index() for efficiency
				my $value_end_pos = -1;
				my $search_pos = 0;

				while ($search_pos < length($buffer)) {
					my $pos = index($buffer, '"', $search_pos);
					last if $pos < 0;  # No more quotes found

					# Count preceding backslashes
					my $backslash_count = 0;
					my $j = $pos - 1;
					while ($j >= 0 && substr($buffer, $j, 1) eq '\\') {
						$backslash_count++;
						$j--;
					}

					# If even number of backslashes (including 0), the quote is not escaped
					if ($backslash_count % 2 == 0) {
						$value_end_pos = $pos;
						last;
					}

					# Quote is escaped, continue searching after this one
					$search_pos = $pos + 1;
				}

				if ($value_end_pos >= 0) {
					# Found complete value! Extract it from buffer
					my $value = substr($buffer, 0, $value_end_pos);

					# Remove value and closing quote from buffer
					$buffer = substr($buffer, $value_end_pos + 1);

					# Skip whitespace after the closing quote
					$buffer =~ s/^\s*//;

					# Remove the comma if present
					if ($buffer =~ /^,/) {
						$buffer = substr($buffer, 1);
					}

					# Clear pending state
					$pendingFileName = "";
					$pendingValue = 0;

					# Properly unescape JSON string escapes from the extracted raw value
					$value =~ s/\\\\/\x00/g;    # Temporarily replace \\ with null byte
					$value =~ s/\\"/"/g;        # \" -> "
					$value =~ s/\\n/\n/g;       # \n -> newline
					$value =~ s/\\r/\r/g;       # \r -> carriage return
					$value =~ s/\\t/\t/g;       # \t -> tab
					$value =~ s/\\b/\b/g;       # \b -> backspace
					$value =~ s/\\f/\f/g;       # \f -> form feed
					$value =~ s/\\\//\//g;      # \/ -> /
					$value =~ s/\x00/\\/g;      # Replace null byte back with single backslash

					$fileCount++;

					# Validate file path
					if ($fileName !~ /^\/?data(\/20[0-9]{2})?\/([\.a-z0-9A-Z\-]+)\.(json|csv|jpg|webp)$/) {
						$errorCount++;
						flushProgress($fileName, "error", "Invalid file path");
					} else {
						# Extract event name
						if ($fileName =~ /data\/(20[0-9]{2}[a-z0-9\-]+)/) {
							$event = $1;
						}

						# Process this file immediately
						my $error = processFile($fileName, $value);
						if ($error) {
							$errorCount++;
							flushProgress($fileName, "error", $error);
						} else {
							flushProgress($fileName, "success", "OK");
						}
					}

					# Continue to next pair
					next;
				} else {
					# Value not complete yet
					if ($is_final_buffer) {
						last;
					} else {
						# Mark that we're waiting for the closing quote, leave partial value in buffer
						$pendingFileName = $fileName;
						$pendingValue = 1;
						last;  # Wait for next chunk
					}
				}
			} else {
				# Value opening quote not found, wait for more data
				if ($is_final_buffer) {
					last;
				} else {
					# Mark pending and wait for next chunk which should have the opening quote
					$pendingFileName = $fileName;
					$pendingValue = 0;
					last;
				}
			}
		} else {
			# No valid key found
			if (length($buffer) > 0 && !$is_final_buffer) {
				# Buffer has partial data that might be a key, keep waiting
			}
			last;
		}
	}
}

# Read chunks and parse JSON key-value pairs
my $chunk;
my $total_bytes_read = 0;
while (read($json_source, $chunk, 8192)) {
	$total_bytes_read += length($chunk);
	$buffer .= $chunk;


	$is_final_buffer = 0;  # More chunks may be coming
	processKeyValuePairs();

}
close($json_source);


# Process any remaining data in the final buffer
if (length($buffer) > 0) {
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

# Redirect if successful, or show link if event exists
if ($event) {
	# Show clickable link when there are errors
	my $eventLink = $cgi->escapeHTML("/event.html#$event");
	print "<p class=\"event-link\"><a href=\"$eventLink\">Go to Event: $event</a></p>\n";
	if ($errorCount == 0) {
		# Auto-redirect after 2 seconds on successful import
		print "<script>setTimeout(function() { window.location.href = '/event.html#$event'; }, 2000);</script>\n";
	}
}

print "</body></html>\n";
