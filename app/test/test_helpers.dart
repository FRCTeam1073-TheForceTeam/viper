import 'package:viper_scout/services/logger_service.dart';

/// Setup for all tests - enables silent logging
void setupTestEnvironment() {
	setTestMode(true);
}

/// Example: Add this at the top of your test file:
/// ```dart
/// import 'test_helpers.dart';
///
/// void main() {
///   setUpAll(() {
///     setupTestEnvironment();  // Silence all logging for this test suite
///   });
///
///   group('MyTests', () {
///     test('example', () {
///       // No logging output will appear
///     });
///   });
/// }
/// ```
