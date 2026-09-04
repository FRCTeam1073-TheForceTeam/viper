import 'package:logger/logger.dart';

/// No-op logger for tests - suppresses all output
class NoOpLogger extends Logger {
	NoOpLogger()
		: super(
			filter: NoOpFilter(),
			printer: NoOpPrinter(),
			output: NoOpOutput(),
		);
}

/// Filter that blocks all log messages
class NoOpFilter extends LogFilter {
	@override
	bool shouldLog(LogEvent event) => false;
}

/// Printer that produces no output
class NoOpPrinter extends LogPrinter {
	@override
	List<String> log(LogEvent event) => [];
}

/// Output that writes nowhere
class NoOpOutput extends LogOutput {
	@override
	void output(OutputEvent event) {
		// No-op: discard all output
	}
}

/// Get a logger that produces no output (for tests)
Logger getTestLogger() => NoOpLogger();
