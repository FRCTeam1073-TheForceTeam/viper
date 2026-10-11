import 'package:logger/logger.dart';

/// Initialize test logging with a silent logger
void setupTestLogging() {
	// Logger is configured via setTestMode() in logger_service.dart
}

/// Replace the global logger with a silent one
Logger getSilentLoggerForTesting() => SilentLogger();

/// Logger that silently discards all output
class SilentLogger extends Logger {
	SilentLogger()
		: super(
			filter: _SilentFilter(),
			printer: _SilentPrinter(),
			output: _SilentOutput(),
		);
}

class _SilentFilter extends LogFilter {
	@override
	bool shouldLog(LogEvent event) => false;
}

class _SilentPrinter extends LogPrinter {
	@override
	List<String> log(LogEvent event) => [];
}

class _SilentOutput extends LogOutput {
	@override
	void output(OutputEvent event) {}
}
