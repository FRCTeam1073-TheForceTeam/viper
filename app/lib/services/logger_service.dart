import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Get logger instance
/// In test mode (detected via kDebugMode or env), returns a silent logger
Logger getLogger() {
	// Check if running in test mode
	if (_isTestMode()) {
		return _getSilentLogger();
	}
	return Logger(printer: SimplePrinter());
}

/// Detect if running in test environment
bool _isTestMode() {
	// Check if debug logging is explicitly enabled via env var
	if (Platform.environment['TEST_DEBUG'] == 'true') {
		return false; // Enable logging when TEST_DEBUG=true
	}
	// Otherwise, rely on test framework setting this up
	return _testModeFlagForTesting;
}

/// Flag to enable silent logging in tests (set via test setup)
bool _testModeFlagForTesting = false;

/// Set test mode flag to control logger behavior
@visibleForTesting
void setTestMode(bool enabled) {
	_testModeFlagForTesting = enabled;
}

/// Create a silent logger that discards all output
Logger _getSilentLogger() {
	return Logger(
		filter: _SilentLogFilter(),
		printer: _SilentLogPrinter(),
		output: _SilentLogOutput(),
	);
}

/// Filter that blocks all log messages in test mode
class _SilentLogFilter extends LogFilter {
	@override
	bool shouldLog(LogEvent event) => false;
}

/// Printer that produces no output
class _SilentLogPrinter extends LogPrinter {
	@override
	List<String> log(LogEvent event) => [];
}

/// Output that writes nowhere
class _SilentLogOutput extends LogOutput {
	@override
	void output(OutputEvent event) {}
}
