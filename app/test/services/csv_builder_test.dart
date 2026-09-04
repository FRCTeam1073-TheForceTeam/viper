import 'package:flutter_test/flutter_test.dart';
import 'package:viper_scout/services/csv_builder.dart';

void main() {
	group('CsvBuilder.safeCSV', () {
		test('escapes tabs to spaces', () {
			expect(CsvBuilder.safeCSV('hello\tworld'), 'hello world');
		});

		test('escapes newlines to ⏎', () {
			expect(CsvBuilder.safeCSV('hello\nworld'), 'hello⏎world');
		});

		test('escapes carriage returns to ⏎', () {
			expect(CsvBuilder.safeCSV('hello\rworld'), 'hello⏎world');
		});

		test('escapes windows newlines \\r\\n to ⏎', () {
			expect(CsvBuilder.safeCSV('hello\r\nworld'), 'hello⏎world');
		});

		test('escapes double quotes to Hebrew character', () {
			expect(CsvBuilder.safeCSV('hello"world'), 'hello״world');
		});

		test('escapes commas to Arabic character', () {
			expect(CsvBuilder.safeCSV('hello,world'), 'hello،world');
		});

		test('handles multiple special characters', () {
			expect(CsvBuilder.safeCSV('a,b"c\nd'), 'a،b״c⏎d');
		});

		test('returns empty string for empty input', () {
			expect(CsvBuilder.safeCSV(''), '');
		});

		test('leaves regular text unchanged', () {
			expect(CsvBuilder.safeCSV('hello world 123'), 'hello world 123');
		});
	});

	group('CsvBuilder.buildScoutCsv', () {
		test('returns empty string for empty list', () {
			expect(CsvBuilder.buildScoutCsv([]), '');
		});

		test('builds single-row CSV', () {
			final csv = CsvBuilder.buildScoutCsv([
				{'teamNumber': '3476', 'matchNumber': 'qm5'},
			]);
			final lines = csv.split('\n');
			expect(lines.length, 2); // header + 1 row
			expect(lines[0], 'team_number,match_number');
			expect(lines[1], '3476,qm5');
		});

		test('converts camelCase to snake_case in headers', () {
			final csv = CsvBuilder.buildScoutCsv([
				{'autoFuelScore': '10', 'autoClimbLevel': '1'},
			]);
			expect(csv, contains('auto_fuel_score'));
			expect(csv, contains('auto_climb_level'));
		});

		test('excludes id, synced, syncedAt fields', () {
			final csv = CsvBuilder.buildScoutCsv([
				{'teamNumber': '123', 'id': 'abc', 'synced': 'true', 'syncedAt': '2026-09-04'},
			]);
			expect(csv, contains('team_number'));
			expect(csv, isNot(contains('id')));
			expect(csv, isNot(contains('synced')));
			expect(csv, isNot(contains('syncedAt')));
		});

		test('escapes field values with special characters', () {
			final csv = CsvBuilder.buildScoutCsv([
				{'comments': 'good,match\nperformance'},
			]);
			expect(csv, contains('good،match⏎performance'));
		});

		test('handles multiple rows with different keys', () {
			final csv = CsvBuilder.buildScoutCsv([
				{'teamNumber': '123', 'matchNumber': 'qm1'},
				{'teamNumber': '456', 'matchNumber': 'qm2', 'comments': 'good'},
			]);
			final lines = csv.split('\n');
			expect(lines.length, 3); // header + 2 rows
			// Header should include teamNumber, matchNumber, comments
			expect(lines[0], contains('team_number'));
			expect(lines[0], contains('match_number'));
			expect(lines[0], contains('comments'));
		});

		test('preserves order of keys from first scout', () {
			final csv = CsvBuilder.buildScoutCsv([
				{'z': '1', 'a': '2', 'm': '3'},
			]);
			final lines = csv.split('\n');
			expect(lines[0], 'z,a,m');
		});

		test('handles null and missing values', () {
			final csv = CsvBuilder.buildScoutCsv([
				{'teamNumber': '123', 'comments': null},
			]);
			expect(csv, contains('123,'));
		});
	});
}
